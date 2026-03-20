import { readContent } from './lib/read-content.js';
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

function stripDirectives(body) {
  const lines = body.split('\n');
  const output = [];
  const stack = [];

  for (const line of lines) {
    const trimmed = line.trim();
    let m;

    if ((m = trimmed.match(/^:::context\[(.+?)\]/))) {
      stack.push({ type: 'context', title: m[1], lines: [] });
      continue;
    }
    if ((m = trimmed.match(/^:::aside\[(.+?)\]/))) {
      stack.push({ type: 'aside', title: m[1], lines: [] });
      continue;
    }
    if (trimmed === ':::prompt') {
      stack.push({ type: 'prompt', lines: [] });
      continue;
    }
    if ((m = trimmed.match(/^:::tabs\{id="(.+?)"\}/))) {
      stack.push({ type: 'tabs', id: m[1], tabs: [] });
      continue;
    }
    if ((m = trimmed.match(/^:::tab\[(.+?)\]/))) {
      // Close previous tab if open inside a tabs block
      if (stack.length && stack[stack.length - 1].type === 'tab') {
        const tab = stack.pop();
        const parent = stack[stack.length - 1];
        if (parent && parent.type === 'tabs') {
          parent.tabs.push({ label: tab.label, content: tab.lines.join('\n') });
        }
      }
      stack.push({ type: 'tab', label: m[1], lines: [] });
      continue;
    }
    if (trimmed === ':::endtabs') {
      // Close current tab
      if (stack.length && stack[stack.length - 1].type === 'tab') {
        const tab = stack.pop();
        const parent = stack[stack.length - 1];
        if (parent && parent.type === 'tabs') {
          parent.tabs.push({ label: tab.label, content: tab.lines.join('\n') });
        }
      }
      // Close tabs group
      if (stack.length && stack[stack.length - 1].type === 'tabs') {
        const tabs = stack.pop();
        const tabOutput = tabs.tabs.map(t => {
          const label = t.label.toLowerCase();
          const emoji = label.includes('mac') ? '🖥' : label.includes('windows') ? '🪟' : '';
          const prefix = emoji ? `${emoji} ` : '';
          return `**${prefix}${t.label}**\n\n${stripDirectives(t.content)}`;
        }).join('\n\n---\n\n');

        if (stack.length) {
          stack[stack.length - 1].lines.push(tabOutput);
        } else {
          output.push(tabOutput);
        }
      }
      continue;
    }
    if (trimmed === ':::time') {
      stack.push({ type: 'time', lines: [] });
      continue;
    }
    if (trimmed === ':::') {
      if (stack.length) {
        const frame = stack.pop();
        const content = frame.lines.join('\n');
        let result = '';

        switch (frame.type) {
          case 'context':
            result = `> **[Context: ${frame.title}]**\n>\n> ${content.split('\n').join('\n> ')}`;
            break;
          case 'aside':
            result = `> **[ℹ️ ${frame.title}]**\n>\n> ${content.split('\n').join('\n> ')}`;
            break;
          case 'prompt':
            result = '```\n' + content + '\n```';
            break;
          case 'time':
            result = ''; // removed entirely
            break;
          case 'tab': {
            // Tab closed by bare :::, push to parent tabs
            const parent = stack[stack.length - 1];
            if (parent && parent.type === 'tabs') {
              parent.tabs.push({ label: frame.label, content: content });
            }
            continue; // don't emit
          }
          default:
            result = content;
        }

        if (result) {
          if (stack.length) {
            stack[stack.length - 1].lines.push(result);
          } else {
            output.push(result);
          }
        }
      }
      continue;
    }

    // Replace inline :def[term]{explanation}
    const processed = line.replace(/:def\[([^\]]+)\]\{([^}]+)\}/g, '$1 ($2)');

    if (stack.length) {
      stack[stack.length - 1].lines.push(processed);
    } else {
      output.push(processed);
    }
  }

  return output.join('\n');
}

// Main
const sections = readContent();
const gdocUrl = process.env.WORKSHOP_GDOC_URL;
const dryRun = process.argv.includes('--dry-run');

if (!dryRun && !gdocUrl) {
  console.error('Error: WORKSHOP_GDOC_URL env var is required');
  process.exit(1);
}

let doc = '';
if (gdocUrl) {
  doc += `---\nurl: ${gdocUrl}\n---\n\n`;
}

sections.forEach((s, i) => {
  if (i > 0) doc += '\n\n---\n\n';
  doc += `# ${s.title}\n\n`;
  if (s.time) doc += `*⏱ ${s.time}*\n\n`;
  doc += stripDirectives(s.body);
});

if (dryRun) {
  console.log(doc);
} else {
  const tmpFile = path.join(import.meta.dirname, '.sync-tmp.md');
  fs.writeFileSync(tmpFile, doc);
  try {
    execSync(`gdoc push "${tmpFile}"`, { stdio: 'inherit' });
    console.log('✓ Content pushed to Google Doc');
  } finally {
    fs.unlinkSync(tmpFile);
  }
}
