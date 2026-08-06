const https = require('https');

https.get('https://firestore.googleapis.com/v1/projects/arisan-antigravity/databases/(default)/documents/groups', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const json = JSON.parse(data);
    const groups = json.documents || [];
    let found = false;
    groups.forEach(group => {
      const name = group.fields?.name?.stringValue;
      if (name && name.toLowerCase().includes('tretan')) {
        console.log(`Found Group: ${name}`);
        const members = group.fields?.members?.arrayValue?.values || [];
        members.forEach(m => {
          const fields = m.mapValue?.fields;
          const waNumber = fields?.waNumber?.stringValue || '';
          const userId = fields?.userId?.stringValue || '';
          const role = fields?.role?.stringValue || 'Member';
          const memberName = fields?.name?.stringValue || '';
          
          if (waNumber.includes('badrusalsyihab') || userId.includes('badrusalsyihab')) {
            console.log(`- Member ${memberName} (${waNumber} / ${userId}) is: ${role}`);
            found = true;
          }
        });
      }
    });
    if (!found) console.log('Did not find the user in the tretan group.');
  });
});
