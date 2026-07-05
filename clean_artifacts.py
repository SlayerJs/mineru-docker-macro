import sys
import glob
import re
import os

def clean_artifacts(dir_path):
    md_files = glob.glob(os.path.join(dir_path, '**', '*.md'), recursive=True)
    if not md_files:
        return
    md_file = md_files[0]
    
    with open(md_file, 'r') as f:
        content = f.read()
    
    img_pattern = re.compile(r'!\[.*?\]\((.*?)\)')
    
    def replacer(match):
        img_path = match.group(1)
        filename = os.path.basename(img_path)
        if "equation" in filename.lower() or "inline" in filename.lower():
            # Try to resolve relative path based on the markdown file's directory
            full_img_path = os.path.join(os.path.dirname(md_file), img_path)
            if os.path.exists(full_img_path):
                try:
                    os.remove(full_img_path)
                except OSError:
                    pass
            elif os.path.exists(img_path):
                try:
                    os.remove(img_path)
                except OSError:
                    pass
            return ''
        else:
            return f'![](images/{filename})'
            
    new_content = img_pattern.sub(replacer, content)
    
    with open(md_file, 'w') as f:
        f.write(new_content)
        
    images_dir = os.path.join(os.path.dirname(md_file), 'images')
    if os.path.exists(images_dir) and os.path.isdir(images_dir):
        if not os.listdir(images_dir):
            try:
                os.rmdir(images_dir)
            except OSError:
                pass

if __name__ == "__main__":
    if len(sys.argv) > 1:
        clean_artifacts(sys.argv[1])
