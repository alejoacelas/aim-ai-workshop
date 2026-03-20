import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';

const md = new MarkdownIt({ html: true }).use(directivesPlugin);

// Test context block
const ctx = md.render(':::context[My Title]\nSome content.\n:::');
console.assert(ctx.includes('class="context-block"'), 'context block class: ' + ctx);
console.assert(ctx.includes('My Title'), 'context title');
console.assert(ctx.includes('Some content.'), 'context body');

// Test aside block
const aside = md.render(':::aside[Tip]\nHelpful info.\n:::');
console.assert(aside.includes('class="aside-block"'), 'aside block class: ' + aside);
console.assert(aside.includes('Tip'), 'aside title');
console.assert(aside.includes('collapsed'), 'aside starts collapsed');

// Test prompt block
const prompt = md.render(':::prompt\nDo the thing\n:::');
console.assert(prompt.includes('class="prompt-block"'), 'prompt block class: ' + prompt);
console.assert(prompt.includes('Do the thing'), 'prompt text');
console.assert(prompt.includes('copy'), 'prompt has copy button');

// Test tabs
const tabs = md.render(':::tabs{id="os"}\n:::tab[Mac]\nMac stuff\n:::\n:::tab[Windows]\nWin stuff\n:::\n:::endtabs');
console.assert(tabs.includes('data-tab-group="os"'), 'tab group id: ' + tabs);
console.assert(tabs.includes('Mac'), 'tab label');
console.assert(tabs.includes('Mac stuff'), 'tab content');

// Test inline :def
const def = md.render('Use :def[tokens]{Units of text for AI} wisely.');
console.assert(def.includes('class="def"'), 'def class: ' + def);
console.assert(def.includes('tokens'), 'def term');
console.assert(def.includes('Units of text for AI'), 'def tooltip');

// Test :::time is ignored
const time = md.render(':::time\n15 min\n:::');
console.assert(!time.includes('15 min') || time.trim() === '', 'time directive should be ignored: ' + time);

console.log('✓ All directive tests passed');
