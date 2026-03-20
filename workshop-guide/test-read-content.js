import { readContent } from './lib/read-content.js';

const sections = readContent();
console.assert(sections.length >= 2, 'Should find at least two content files');
console.assert(sections[0].order <= sections[1].order, 'Should be sorted by order');
console.assert(sections[0].title, 'Each section should have a title');
console.assert(sections[0].id, 'Each section should have an id');
console.assert(sections[0].time, 'Each section should have a time');
console.assert(sections[0].body, 'Each section should have a body');
console.log(`✓ Found ${sections.length} sections, sorted by order`);
sections.forEach(s => console.log(`  ${s.order}: ${s.title} (${s.time})`));
