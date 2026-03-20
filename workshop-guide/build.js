import fs from 'fs';
import path from 'path';
import MarkdownIt from 'markdown-it';
import { directivesPlugin } from './lib/parse-directives.js';
import { readContent } from './lib/read-content.js';
import { renderPage } from './lib/template.js';

const md = new MarkdownIt({ html: true, linkify: true }).use(directivesPlugin);

const sections = readContent();
const renderedSections = sections.map(s => ({
  id: s.id,
  title: s.title,
  time: s.time,
  order: s.order,
  html: md.render(s.body),
}));

const distDir = path.resolve(import.meta.dirname, 'dist');
fs.mkdirSync(distDir, { recursive: true });

const html = renderPage(sections, renderedSections);
fs.writeFileSync(path.join(distDir, 'index.html'), html);
console.log(`Built dist/index.html (${(html.length / 1024).toFixed(1)} KB)`);
