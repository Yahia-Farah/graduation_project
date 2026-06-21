import os, re

def convert(match):
    s = match.group(0)
    if '.toArabicNumbers()' in s:
        return s
    
    return match.group(1) + '(' + match.group(2) + match.group(3) + match.group(2) + ').toArabicNumbers()' + match.group(4)

directory = r'c:\Users\newuser\StudioProjects\el_mostashar\lib'
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = re.sub(r'(Text\s*\(\s*)([\'\"])([^\\\'\"]*?\$[^{]*?[^\\\'\"]*?)\2(\s*\))', convert, content)
            new_content = re.sub(r'(Text\s*\(\s*)([\'\"])([^\\\'\"]*?\$\{[^}]+\}[^\\\'\"]*?)\2(\s*\))', convert, new_content)
            
            if new_content != content:
                if 'toArabicNumbers' in new_content and 'arabic_numbers_extension.dart' not in new_content:
                    last_import = new_content.rfind('import ')
                    if last_import != -1:
                        end_of_line = new_content.find('\n', last_import)
                        new_content = new_content[:end_of_line+1] + "import 'package:el_mostashar/core/utils/arabic_numbers_extension.dart';\n" + new_content[end_of_line+1:]
                
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Updated {path}')
