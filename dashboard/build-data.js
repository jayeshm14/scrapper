const fs = require('fs');
const path = require('path');

const outputDir = path.join(__dirname, '..', 'output');
const sites = ['99acres', 'magicbricks', 'squareyards', 'olx', 'proptiger'];
const allProps = [];

for (const site of sites) {
  const siteDir = path.join(outputDir, site);
  if (!fs.existsSync(siteDir)) continue;
  
  const files = fs.readdirSync(siteDir).filter(f => f.endsWith('.json') && f !== '.seen.json');
  for (const file of files) {
    try {
      let content = fs.readFileSync(path.join(siteDir, file), 'utf8');
      // Remove BOM if present
      if (content.charCodeAt(0) === 0xFEFF) {
        content = content.slice(1);
      }
      const data = JSON.parse(content);
      if (Array.isArray(data)) {
        allProps.push(...data);
      } else {
        allProps.push(data);
      }
    } catch (e) {
      console.error(`Error reading ${file}:`, e.message);
    }
  }
}

const outputPath = path.join(__dirname, 'data.json');
fs.writeFileSync(outputPath, JSON.stringify(allProps, null, 2));
console.log(`Wrote ${allProps.length} properties to data.json`);
