import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';

const CONTENT_DIR = path.resolve(import.meta.dirname, '..', '..', 'content');

export function readContent() {
  const files = fs.readdirSync(CONTENT_DIR)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const raw = fs.readFileSync(path.join(CONTENT_DIR, f), 'utf-8');
      const { data, content } = matter(raw);
      return {
        title: data.title,
        id: data.id,
        time: data.time || '',
        order: data.order ?? 99,
        body: content.trim(),
        filename: f,
      };
    });
  files.sort((a, b) => a.order - b.order);
  return files;
}
