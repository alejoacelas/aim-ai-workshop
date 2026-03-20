/**
 * Renders a complete self-contained HTML page for the workshop guide.
 *
 * @param {Array<{title: string, id: string, time: string, order: number}>} sections - For sidebar
 * @param {Array<{id: string, title: string, time: string, html: string, order: number}>} renderedSections - For content
 * @returns {string} Complete HTML string
 */
export function renderPage(sections, renderedSections) {
  const totalMinutes = sections.reduce((sum, s) => {
    const m = parseInt(s.time, 10);
    return sum + (isNaN(m) ? 0 : m);
  }, 0);
  const totalTime = totalMinutes > 0 ? `${totalMinutes} min total` : '';

  const sidebarLinks = sections
    .map(
      s => `
      <a class="sidebar-link" href="#${s.id}">
        <span class="sidebar-link-title">${escapeHtml(s.title)}</span>
        <span class="sidebar-link-time">${escapeHtml(s.time)}</span>
      </a>`
    )
    .join('\n');

  const contentSections = renderedSections
    .map((s, i) => {
      const label =
        s.order >= 1
          ? `<div class="section-label">T${s.order - 1} · ${escapeHtml(s.time)}</div>`
          : `<div class="section-label">${escapeHtml(s.time)}</div>`;
      const hr = i < renderedSections.length - 1 ? '<hr>' : '';
      return `
<section id="${s.id}">
${label}
${s.html}
</section>
${hr}`;
    })
    .join('\n');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Coding agents 101</title>
  <style>
    html { scroll-behavior: smooth; }

    *, *::before, *::after { box-sizing: border-box; }

    body {
      background: #111;
      color: #bbb;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 14px;
      line-height: 1.7;
      margin: 0;
    }

    /* Sidebar */
    .sidebar {
      background: #0d0d0d;
      width: 220px;
      position: fixed;
      top: 0;
      left: 0;
      height: 100vh;
      border-right: 1px solid #222;
      overflow-y: auto;
      padding: 20px 16px;
      display: flex;
      flex-direction: column;
    }

    .sidebar-title {
      color: #fff;
      font-size: 15px;
      font-weight: 700;
      margin: 0 0 4px 0;
    }

    .sidebar-total-time {
      color: #555;
      font-size: 11px;
      margin-bottom: 16px;
    }

    .sidebar-nav {
      flex: 1;
    }

    .sidebar-link {
      display: block;
      padding: 8px 12px;
      border-radius: 5px;
      text-decoration: none;
      color: #888;
      font-size: 13px;
      margin-bottom: 2px;
      border-left: 2px solid transparent;
    }

    .sidebar-link-title {
      display: block;
    }

    .sidebar-link-time {
      color: #444;
      font-size: 11px;
    }

    .sidebar-link.active {
      background: #1c1710;
      border-left-color: #e6a030;
      color: #e6a030;
    }

    .sidebar-link.active .sidebar-link-time {
      color: #7a5a20;
    }

    .progress-bar {
      background: #222;
      height: 4px;
      border-radius: 2px;
      margin-top: 16px;
      overflow: hidden;
    }

    .progress-fill {
      background: #e6a030;
      height: 100%;
      width: 0%;
      border-radius: 2px;
      transition: width 0.3s ease;
    }

    /* Content */
    .content {
      margin-left: 220px;
      padding: 40px 48px;
      max-width: 720px;
    }

    .section-label {
      font-size: 11px;
      color: #555;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 4px;
    }

    h1 { font-size: 28px; font-weight: 700; color: #fff; margin-top: 8px; }
    h2 { font-size: 20px; font-weight: 600; color: #eee; }
    h3 { font-size: 16px; font-weight: 600; color: #ddd; }

    a { color: #e6a030; }

    strong { color: #ddd; }

    code {
      background: #1e1e1e;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 13px;
    }

    hr {
      border: none;
      border-top: 1px solid #222;
      margin: 32px 0;
    }

    ul, ol { padding-left: 20px; }
    li { margin-bottom: 4px; }

    /* Context blocks */
    .context-block {
      background: #1c1710;
      border-left: 3px solid #e6a030;
      padding: 16px 20px;
      border-radius: 0 8px 8px 0;
      margin: 24px 0;
    }

    .context-title {
      color: #e6a030;
      font-weight: 600;
      font-size: 14px;
      margin-bottom: 6px;
    }

    .context-body {
      color: #bbb;
    }

    /* Aside blocks */
    .aside-block {
      background: #0d1a1e;
      border: 1px solid #2a4045;
      border-radius: 8px;
      margin: 24px 0;
      overflow: hidden;
    }

    .aside-header {
      padding: 12px 16px;
      cursor: pointer;
      display: flex;
      justify-content: space-between;
      align-items: center;
      user-select: none;
    }

    .aside-title {
      color: #50b0b0;
      font-size: 13px;
      font-weight: 500;
    }

    .aside-chevron {
      color: #50b0b0;
      transition: transform 0.2s;
      font-style: normal;
    }

    .aside-block.collapsed .aside-chevron::after { content: '▸'; }
    .aside-block:not(.collapsed) .aside-chevron::after { content: '▾'; }

    .aside-body {
      padding: 0 16px 16px 16px;
      color: #bbb;
    }

    .aside-block.collapsed .aside-body {
      display: none;
    }

    /* Prompt blocks */
    .prompt-block {
      background: #1a1a2e;
      border: 1px solid #2a2a40;
      border-radius: 6px;
      padding: 12px 16px;
      margin: 16px 0;
      position: relative;
      font-family: monospace;
      font-size: 13px;
      color: #ccc;
    }

    .copy-btn {
      position: absolute;
      top: 8px;
      right: 8px;
      background: #252540;
      border: none;
      color: #555;
      padding: 2px 8px;
      border-radius: 3px;
      cursor: pointer;
      font-size: 11px;
    }

    .copy-btn:hover { color: #aaa; }

    .prompt-block pre {
      margin: 0;
      white-space: pre-wrap;
      word-wrap: break-word;
      font-family: inherit;
      font-size: inherit;
      color: inherit;
    }

    /* Tab groups */
    .tab-group {
      border: 1px solid #333;
      border-radius: 8px;
      overflow: hidden;
      margin: 24px 0;
    }

    .tab-bar {
      display: flex;
      border-bottom: 1px solid #333;
      background: #0d0d0d;
    }

    .tab-btn {
      padding: 10px 20px;
      font-size: 13px;
      color: #666;
      background: transparent;
      border: none;
      cursor: pointer;
      border-bottom: 2px solid transparent;
    }

    .tab-btn.active {
      color: #cc66cc;
      border-bottom-color: #cc66cc;
      background: #2a1e2a;
    }

    .tab-panel {
      padding: 20px;
      display: none;
    }

    .tab-panel.active {
      display: block;
    }

    /* Definition tooltips */
    .def {
      border-bottom: 1px dotted #888;
      cursor: help;
    }

    .def sup {
      font-size: 10px;
      color: #888;
      margin-left: 1px;
    }
  </style>
</head>
<body>

<div class="sidebar">
  <div class="sidebar-title">Coding agents 101</div>
  ${totalTime ? `<div class="sidebar-total-time">${escapeHtml(totalTime)}</div>` : ''}
  <nav class="sidebar-nav">
    ${sidebarLinks}
  </nav>
  <div class="progress-bar">
    <div class="progress-fill"></div>
  </div>
</div>

<div class="content">
  ${contentSections}
</div>

<script>
  // Scroll tracking with IntersectionObserver
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.sidebar-link');
  const progressFill = document.querySelector('.progress-fill');

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        navLinks.forEach(link => link.classList.remove('active'));
        const activeLink = document.querySelector(\`.sidebar-link[href="#\${entry.target.id}"]\`);
        if (activeLink) activeLink.classList.add('active');

        // Update progress
        const idx = Array.from(sections).indexOf(entry.target);
        const progress = ((idx + 1) / sections.length) * 100;
        if (progressFill) progressFill.style.width = progress + '%';
      }
    });
  }, { threshold: 0.1, rootMargin: '-20% 0px -70% 0px' });

  sections.forEach(s => observer.observe(s));

  // Tab switching with localStorage persistence
  document.addEventListener('click', e => {
    const btn = e.target.closest('.tab-btn');
    if (!btn) return;

    const group = btn.closest('.tab-group');
    const groupId = group.dataset.tabGroup;
    const tabName = btn.dataset.tab;

    // Save preference
    localStorage.setItem('tab-' + groupId, tabName);

    // Update ALL groups with same ID
    document.querySelectorAll(\`.tab-group[data-tab-group="\${groupId}"]\`).forEach(g => {
      g.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === tabName));
      g.querySelectorAll('.tab-panel').forEach(p => p.classList.toggle('active', p.dataset.tab === tabName));
    });
  });

  // Restore saved tabs on load
  document.querySelectorAll('.tab-group').forEach(group => {
    const groupId = group.dataset.tabGroup;
    const saved = localStorage.getItem('tab-' + groupId);
    if (saved) {
      group.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === saved));
      group.querySelectorAll('.tab-panel').forEach(p => p.classList.toggle('active', p.dataset.tab === saved));
    }
  });

  // Copy to clipboard
  function copyPrompt(btn) {
    const pre = btn.parentElement.querySelector('pre');
    navigator.clipboard.writeText(pre.textContent).then(() => {
      btn.textContent = '✓ copied';
      setTimeout(() => btn.textContent = '📋 copy', 2000);
    });
  }

  // Smooth scroll for sidebar links
  document.querySelectorAll('.sidebar-link').forEach(link => {
    link.addEventListener('click', e => {
      e.preventDefault();
      const target = document.querySelector(link.getAttribute('href'));
      if (target) target.scrollIntoView({ behavior: 'smooth' });
    });
  });
</script>

</body>
</html>`;
}

/**
 * Escapes HTML special characters in a string.
 * @param {string} str
 * @returns {string}
 */
function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
