import { readContent } from './lib/read-content.js';
import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';

const md = new MarkdownIt({ html: true }).use(directivesPlugin);
const sections = readContent();
let allPassed = true;
sections.forEach(s => {
  try {
    const html = md.render(s.body);
    console.log(`✓ ${s.filename}: ${html.length} chars HTML`);
    // Basic sanity checks
    if (s.filename === '01-install.md') {
      console.assert(html.includes('data-tab-group="agent"'), '01-install should have agent tabs');
      console.assert(html.includes('data-tab-group="os"'), '01-install should have os tabs');
      console.assert(html.includes('class="context-block"'), '01-install should have context block');
      console.assert(html.includes('class="prompt-block"'), '01-install should have prompt blocks');
      console.assert(html.includes('class="aside-block"'), '01-install should have aside blocks');
    }
  } catch (e) {
    console.error(`✗ ${s.filename}: ${e.message}`);
    allPassed = false;
  }
});
if (allPassed) console.log('\n✓ All content files rendered successfully');
else process.exit(1);
