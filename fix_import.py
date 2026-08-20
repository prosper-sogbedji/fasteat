import os

SCREEN_DIR = 'lib/screens'

for root, dirs, files in os.walk(SCREEN_DIR):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'package:fasteat' in content:
                content = content.replace('package:fasteat', 'package:fast_eat')
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filepath}")
