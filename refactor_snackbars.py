import os
import re

SCREEN_DIR = 'lib/screens'

# Regex to match ScaffoldMessenger.of(context).showSnackBar(...)
pattern = re.compile(
    r'ScaffoldMessenger\.of\((\w+)\)\.showSnackBar\(\s*(?:const\s+)?SnackBar\([\s\S]*?content:\s*Text\(([\s\S]*?)\)[\s\S]*?\)\s*,\s*\)?;?',
    re.MULTILINE
)

import_statement = "import 'package:fasteat/widgets/common/app_feedback.dart';\n"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'ScaffoldMessenger' not in content:
        return

    def replacer(match):
        context_var = match.group(1)
        text_content = match.group(2).strip()
        
        orig_match = match.group(0).lower()
        if 'erreur' in orig_match or 'red' in orig_match or 'chec' in orig_match or 'impossible' in orig_match or 'vide' in orig_match or 'non reconnu' in orig_match:
            feedback_type = 'error'
        elif 'succès' in orig_match or 'ajouté' in orig_match or 'merci' in orig_match or 'bienvenue' in orig_match or 'annulée' in orig_match:
            feedback_type = 'success'
        else:
            feedback_type = 'info'
            
        return f"AppFeedback.{feedback_type}({context_var}, {text_content});"

    new_content, count = pattern.subn(replacer, content)

    if count > 0:
        if 'app_feedback.dart' not in new_content:
            new_content = re.sub(r'^(import .*?;)', r'\1\n' + import_statement, new_content, count=1, flags=re.MULTILINE)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath} ({count} replacements)")

for root, dirs, files in os.walk(SCREEN_DIR):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
