import os

def remove_snackbars_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    out = ""
    i = 0
    changed = False
    while i < len(content):
        idx = content.find("ScaffoldMessenger.of(context).showSnackBar", i)
        
        if idx == -1:
            out += content[i:]
            break
            
        out += content[i:idx]
        out += "/* "
        
        j = idx
        paren_count = 0
        found_first_paren = False
        while j < len(content):
            if content[j] == '(':
                paren_count += 1
                found_first_paren = True
            elif content[j] == ')':
                paren_count -= 1
            
            j += 1
            if found_first_paren and paren_count == 0:
                # now find the semicolon
                while j < len(content) and content[j] in [' ', '\n', '\t', '\r']:
                    j += 1
                if j < len(content) and content[j] == ';':
                    j += 1
                break
        
        out += content[idx:j]
        out += " */"
        i = j
        changed = True
        
    if changed:
        print(f"Modified {filepath}")
        with open(filepath, 'w') as f:
            f.write(out)

for root, _, files in os.walk('/Users/badrus/project_badrus/app_arisan_antigravity/lib'):
    for file in files:
        if file.endswith('.dart'):
            remove_snackbars_in_file(os.path.join(root, file))
