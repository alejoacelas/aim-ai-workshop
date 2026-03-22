interface Env {
  DB: D1Database;
  OPENROUTER_API_KEY: string;
}

const SYSTEM_PROMPT_ERROR = `You're helping a non-technical person who is installing software for a workshop. The command they ran failed.

- Explain in one plain sentence what happened (no jargon, no technical terms)
- Provide the exact shell commands to fix it, one per line
- If relevant prior commands in the log history provide context, use them
- If the "Command" looks like a natural-language request instead of a real shell command, treat it like a question and explain the steps plainly
- For natural-language requests, put any real commands they should run in fix_commands

Respond in JSON: { "ok": false, "explanation": "...", "fix_commands": ["cmd1", "cmd2"] }
Only output valid JSON, nothing else.`;

const SYSTEM_PROMPT_SUCCESS = `You're helping a non-technical person who is installing software for a workshop. The command they ran succeeded.

Write one short, friendly sentence describing what the command did or achieved. No jargon—imagine you're explaining to someone who has never used a terminal. Don't mention exit codes or technical details.

Respond in JSON: { "ok": true, "explanation": "...", "fix_commands": [] }
Only output valid JSON, nothing else.`;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
        },
      });
    }

    if (request.method === "POST" && url.pathname === "/analyze") {
      return handleAnalyze(request, env);
    }

    if (request.method === "POST" && url.pathname === "/install") {
      return handleInstall(request, env);
    }

    if (request.method === "POST" && url.pathname === "/subscribe") {
      return handleSubscribe(request, env);
    }

    if (request.method === "GET" && url.pathname === "/logs") {
      return handleLogs(env);
    }

    return new Response("Not found", { status: 404 });
  },
};

async function handleAnalyze(request: Request, env: Env): Promise<Response> {
  const body = await request.json<{
    command: string;
    stdout: string;
    stderr: string;
    exit_code: number;
    os: string;
    shell: string;
    log_history: Array<{ command: string; stdout: string; stderr: string; exit_code: number }>;
    session_id?: string;
  }>();

  const { command, stdout, stderr, exit_code, os, shell, log_history, session_id } = body;

  // Build the user message with context
  const historyContext =
    log_history && log_history.length > 0
      ? `\n\nPrevious commands in this session:\n${log_history
          .slice(-5) // last 5 entries for context
          .map((h) => `$ ${h.command} (exit ${h.exit_code})${h.stderr ? `\nstderr: ${h.stderr.slice(0, 300)}` : ""}`)
          .join("\n\n")}`
      : "";

  const userMessage = `OS: ${os}
Shell: ${shell}
Command: ${command}
Exit code: ${exit_code}
stdout: ${stdout.slice(0, 2000)}
stderr: ${stderr.slice(0, 2000)}${historyContext}`;

  // Call OpenRouter
  const apiKey = env.OPENROUTER_API_KEY;
  if (!apiKey) {
    return jsonResponse({ ok: false, explanation: "Server config error: API key not set", fix_commands: [] }, 500);
  }
  const llmResponse = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "google/gemini-3-flash-preview",
      messages: [
        { role: "system", content: exit_code === 0 ? SYSTEM_PROMPT_SUCCESS : SYSTEM_PROMPT_ERROR },
        { role: "user", content: userMessage },
      ],
      temperature: 0.2,
    }),
  });

  if (!llmResponse.ok) {
    const errText = await llmResponse.text();
    console.error("OpenRouter error:", llmResponse.status, errText);
    return jsonResponse({ ok: false, explanation: "Analysis service unavailable. Try again in a moment.", fix_commands: [] }, 502);
  }

  const llmData = await llmResponse.json<{
    choices: Array<{ message: { content: string } }>;
  }>();

  let result: { ok: boolean; explanation: string; fix_commands: string[] };
  try {
    const content = llmData.choices[0].message.content;
    // Strip markdown code fences if present
    const cleaned = content.replace(/^```json?\s*\n?/i, "").replace(/\n?```\s*$/i, "");
    result = JSON.parse(cleaned);
  } catch {
    result = { ok: false, explanation: "Could not parse analysis. The command may have failed—check the output above.", fix_commands: [] };
  }

  // Log to D1
  try {
    await env.DB.prepare(
      `INSERT INTO errors (os, shell, command, stdout_snippet, stderr_snippet, exit_code, explanation, fix_commands, session_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        os || "",
        shell || "",
        command || "",
        (stdout || "").slice(0, 500),
        (stderr || "").slice(0, 500),
        exit_code,
        result.explanation || "",
        JSON.stringify(result.fix_commands || []),
        session_id || ""
      )
      .run();
  } catch {
    // Don't fail the request if logging fails
  }

  return jsonResponse(result);
}

async function handleInstall(request: Request, env: Env): Promise<Response> {
  const body = await request.json<{
    os?: string;
    success?: boolean;
    step?: string;
    error?: string;
  }>();

  const os = body.os || "";
  const success = body.success ? 1 : 0;
  const step = body.step || "";
  const error = body.error || "";

  try {
    await env.DB.prepare(
      `INSERT INTO installs (os, success, step, error)
       VALUES (?, ?, ?, ?)`
    )
      .bind(os, success, step, error)
      .run();
  } catch {
    // Telemetry must not fail the installer
  }

  return jsonResponse({ ok: true });
}

async function handleSubscribe(request: Request, env: Env): Promise<Response> {
  const body = await request.json<{ email: string }>();
  const email = (body.email || "").trim().toLowerCase();

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return jsonResponse({ ok: false, error: "Invalid email" }, 400);
  }

  try {
    await env.DB.prepare(
      "INSERT OR IGNORE INTO subscribers (email) VALUES (?)"
    ).bind(email).run();
  } catch {
    // ignore
  }

  return jsonResponse({ ok: true });
}

async function handleLogs(env: Env): Promise<Response> {
  let rows: Array<Record<string, unknown>> = [];
  let installs: Array<Record<string, unknown>> = [];
  try {
    const result = await env.DB.prepare(
      "SELECT * FROM errors ORDER BY timestamp DESC LIMIT 200"
    ).all();
    rows = result.results || [];
  } catch {
    // DB might not be initialized yet
  }

  try {
    const result = await env.DB.prepare(
      "SELECT * FROM installs ORDER BY timestamp DESC LIMIT 200"
    ).all();
    installs = result.results || [];
  } catch {
    // DB might not be initialized yet
  }

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>helpme — Error Dashboard</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #e2e8f0; padding: 1.5rem; }
  h1 { font-size: 1.5rem; margin-bottom: 1rem; color: #f8fafc; }
  .stats { display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
  .stat { background: #1e293b; border-radius: 8px; padding: 1rem 1.5rem; }
  .stat-value { font-size: 1.5rem; font-weight: 700; color: #38bdf8; }
  .stat-label { font-size: 0.8rem; color: #94a3b8; }
  .filters { margin-bottom: 1rem; display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .filters input, .filters select { background: #1e293b; border: 1px solid #334155; color: #e2e8f0; padding: 0.4rem 0.8rem; border-radius: 6px; font-size: 0.85rem; }
  table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
  th { background: #1e293b; color: #94a3b8; text-align: left; padding: 0.6rem 0.8rem; cursor: pointer; user-select: none; position: sticky; top: 0; }
  th:hover { color: #e2e8f0; }
  td { padding: 0.6rem 0.8rem; border-bottom: 1px solid #1e293b; max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  td:hover { white-space: normal; word-break: break-all; }
  tr:hover { background: #1e293b; }
  .ok { color: #4ade80; }
  .err { color: #f87171; }
  .empty { text-align: center; padding: 3rem; color: #64748b; }
</style>
</head>
<body>
<h1>helpme — Error Dashboard</h1>
<div class="stats">
  <div class="stat"><div class="stat-value" id="total">0</div><div class="stat-label">Total requests</div></div>
  <div class="stat"><div class="stat-value" id="errors">0</div><div class="stat-label">Errors</div></div>
  <div class="stat"><div class="stat-value" id="unique-cmds">0</div><div class="stat-label">Unique commands</div></div>
  <div class="stat"><div class="stat-value" id="installs-total">0</div><div class="stat-label">Install attempts</div></div>
  <div class="stat"><div class="stat-value" id="installs-success">0</div><div class="stat-label">Install successes</div></div>
  <div class="stat"><div class="stat-value" id="installs-failed">0</div><div class="stat-label">Install failures</div></div>
</div>
<div class="filters">
  <input type="text" id="search" placeholder="Search commands or errors…">
  <select id="os-filter"><option value="">All OS</option></select>
</div>
<table>
  <thead>
    <tr>
      <th data-col="timestamp">Time</th>
      <th data-col="os">OS</th>
      <th data-col="shell">Shell</th>
      <th data-col="command">Command</th>
      <th data-col="exit_code">Exit</th>
      <th data-col="stderr_snippet">stderr</th>
      <th data-col="explanation">Explanation</th>
      <th data-col="fix_commands">Fix</th>
    </tr>
  </thead>
  <tbody id="tbody"></tbody>
</table>
<h1 style="margin-top: 2rem;">Install Telemetry</h1>
<table>
  <thead>
    <tr>
      <th>Time</th>
      <th>OS</th>
      <th>Success</th>
      <th>Step</th>
      <th>Error</th>
    </tr>
  </thead>
  <tbody id="installs-tbody"></tbody>
</table>
<script>
const data = ${JSON.stringify(rows)};
const installs = ${JSON.stringify(installs)};
const tbody = document.getElementById('tbody');
const installsTbody = document.getElementById('installs-tbody');
const searchInput = document.getElementById('search');
const osFilter = document.getElementById('os-filter');

// Stats
document.getElementById('total').textContent = data.length;
document.getElementById('errors').textContent = data.filter(r => r.exit_code !== 0).length;
document.getElementById('unique-cmds').textContent = new Set(data.map(r => r.command)).size;
document.getElementById('installs-total').textContent = installs.length;
document.getElementById('installs-success').textContent = installs.filter(r => Number(r.success) === 1).length;
document.getElementById('installs-failed').textContent = installs.filter(r => Number(r.success) !== 1).length;

// OS filter options
const oses = [...new Set(data.map(r => r.os).filter(Boolean))];
oses.forEach(os => { const o = document.createElement('option'); o.value = os; o.textContent = os; osFilter.appendChild(o); });

function render(rows) {
  if (rows.length === 0) {
    tbody.innerHTML = '<tr><td colspan="8" class="empty">No entries yet</td></tr>';
    return;
  }
  tbody.innerHTML = rows.map(r => {
    const exitClass = r.exit_code === 0 ? 'ok' : 'err';
    const fixes = (() => { try { return JSON.parse(r.fix_commands || '[]').join('; '); } catch { return r.fix_commands; } })();
    return \`<tr>
      <td>\${r.timestamp || ''}</td>
      <td>\${r.os || ''}</td>
      <td>\${r.shell || ''}</td>
      <td>\${r.command || ''}</td>
      <td class="\${exitClass}">\${r.exit_code ?? ''}</td>
      <td>\${r.stderr_snippet || ''}</td>
      <td>\${r.explanation || ''}</td>
      <td>\${fixes || ''}</td>
    </tr>\`;
  }).join('');
}

function renderInstalls(rows) {
  if (rows.length === 0) {
    installsTbody.innerHTML = '<tr><td colspan="5" class="empty">No install events yet</td></tr>';
    return;
  }
  installsTbody.innerHTML = rows.map(r => {
    const success = Number(r.success) === 1;
    return \`<tr>
      <td>\${r.timestamp || ''}</td>
      <td>\${r.os || ''}</td>
      <td class="\${success ? 'ok' : 'err'}">\${success ? 'yes' : 'no'}</td>
      <td>\${r.step || ''}</td>
      <td>\${r.error || ''}</td>
    </tr>\`;
  }).join('');
}

function applyFilters() {
  let filtered = data;
  const q = searchInput.value.toLowerCase();
  const os = osFilter.value;
  if (q) filtered = filtered.filter(r => (r.command || '').toLowerCase().includes(q) || (r.explanation || '').toLowerCase().includes(q) || (r.stderr_snippet || '').toLowerCase().includes(q));
  if (os) filtered = filtered.filter(r => r.os === os);
  render(filtered);
}

searchInput.addEventListener('input', applyFilters);
osFilter.addEventListener('change', applyFilters);

// Sort
let sortCol = 'timestamp', sortDir = -1;
document.querySelectorAll('th[data-col]').forEach(th => {
  th.addEventListener('click', () => {
    const col = th.dataset.col;
    if (sortCol === col) sortDir *= -1; else { sortCol = col; sortDir = 1; }
    data.sort((a, b) => {
      const va = a[col] ?? '', vb = b[col] ?? '';
      return (va < vb ? -1 : va > vb ? 1 : 0) * sortDir;
    });
    applyFilters();
  });
});

render(data);
renderInstalls(installs);
</script>
</body>
</html>`;

  return new Response(html, {
    headers: { "Content-Type": "text/html; charset=utf-8" },
  });
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
