import urllib.request
import json

url = 'https://firestore.googleapis.com/v1/projects/arisan-antigravity/databases/(default)/documents/groups'
try:
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
        groups = data.get('documents', [])
        for group in groups:
            name = group.get('fields', {}).get('name', {}).get('stringValue', '')
            if 'tretan' in name.lower():
                print(f"Group: {name}, ID: {group.get('name').split('/')[-1]}")
except Exception as e:
    print(e)
