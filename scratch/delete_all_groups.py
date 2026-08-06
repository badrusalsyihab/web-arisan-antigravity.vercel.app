import urllib.request
import json

url = 'https://firestore.googleapis.com/v1/projects/arisan-antigravity/databases/(default)/documents/groups'
try:
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
        groups = data.get('documents', [])
        if not groups:
            print("No groups found to delete.")
        
        for group in groups:
            doc_name = group.get('name')
            doc_id = doc_name.split('/')[-1]
            print(f"Deleting group {doc_id}...")
            
            req = urllib.request.Request(f"https://firestore.googleapis.com/v1/{doc_name}", method='DELETE')
            with urllib.request.urlopen(req) as del_res:
                print(f"Deleted {doc_id}")
                
except Exception as e:
    print(f"Error: {e}")
