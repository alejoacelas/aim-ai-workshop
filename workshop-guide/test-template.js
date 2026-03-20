import { renderPage } from './lib/template.js';

const sections = [
  { title: 'Start here', id: 'start', time: '5 min', order: 0 },
  { title: 'T0: Install', id: 'install', time: '15 min', order: 1 },
];
const rendered = [
  { id: 'start', title: 'Start here', time: '5 min', order: 0, html: '<h1>Start here</h1><p>Hello</p>' },
  { id: 'install', title: 'T0: Install', time: '15 min', order: 1, html: '<h1>Install</h1><p>World</p>' },
];

const html = renderPage(sections, rendered);
console.assert(html.includes('<!DOCTYPE html>'), 'has doctype');
console.assert(html.includes('Start here'), 'sidebar has section');
console.assert(html.includes('15 min'), 'sidebar has time');
console.assert(html.includes('id="start"'), 'content has section id');
console.assert(html.includes('<p>Hello</p>'), 'content has rendered HTML');
console.assert(html.includes('IntersectionObserver'), 'has scroll tracking JS');
console.assert(html.includes('localStorage'), 'has tab persistence JS');
console.assert(html.includes('copyPrompt'), 'has copy function');
console.assert(html.includes('scroll-behavior'), 'has smooth scroll CSS');
console.log(`✓ Template renders ${html.length} chars`);
