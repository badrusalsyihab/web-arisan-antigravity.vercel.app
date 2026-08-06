import urllib.request
import json

url = 'https://firestore.googleapis.com/v1/projects/arisan-antigravity/databases/(default)/documents/groups'
try:
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
        groups = data.get('documents', [])
        for group in groups:
            fields = group.get('fields', {})
            name = fields.get('name', {}).get('stringValue', '')
            if 'tretan' in name.lower():
                print(f"Group: {name}")
                members = fields.get('members', {}).get('arrayValue', {}).get('values', [])
                for m in members:
                    m_fields = m.get('mapValue', {}).get('fields', {})
                    waNumber = m_fields.get('waNumber', {}).get('stringValue', '')
                    userId = m_fields.get('userId', {}).get('stringValue', '')
                    role = m_fields.get('role', {}).get('stringValue', 'Member')
                    memberName = m_fields.get('name', {}).get('stringValue', '')
                    
                    print(f"- Member {memberName} ({waNumber} / userId:{userId}) is: {role}")
except Exception as e:
    print(e)
