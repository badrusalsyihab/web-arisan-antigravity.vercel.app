import os

def fix_snackbars_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Undo the bad comments
    content = content.replace("/* ScaffoldMessenger.of(context) */", "ScaffoldMessenger.of(context)")
    
    # Now let's correctly comment out the whole statement.
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
        
        j = idx + len("ScaffoldMessenger.of(context).showSnackBar")
        
        # Find the first '('
        while j < len(content) and content[j] != '(':
            j += 1
            
        if j < len(content):
            paren_count = 1
            j += 1
            while j < len(content) and paren_count > 0:
                if content[j] == '(':
                    paren_count += 1
                elif content[j] == ')':
                    paren_count -= 1
                j += 1
            
            # now find the semicolon
            while j < len(content) and content[j] in [' ', '\n', '\t', '\r']:
                j += 1
            if j < len(content) and content[j] == ';':
                j += 1
        
        out += content[idx:j]
        out += " */"
        i = j
        changed = True
        
    if changed:
        print(f"Fixed {filepath}")
        with open(filepath, 'w') as f:
            f.write(out)

for root, _, files in os.walk('/Users/badrus/project_badrus/app_arisan_antigravity/lib'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r') as f:
                c = f.read()
            if "/* ScaffoldMessenger" in c or "ScaffoldMessenger.of(context).showSnackBar" in c:
                fix_snackbars_in_file(os.path.join(root, file))
