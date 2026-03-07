# MCP Servers, Connectors & Skills for Common Founder Tools

A curated list of ways to connect Claude Code (and Claude Desktop) to the tools CE founders commonly use. For each tool, options are listed with setup difficulty and links.

---

## Slack

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Slack Official MCP** | MCP (remote) | [docs.slack.dev](https://docs.slack.dev/ai/slack-mcp-server/connect-to-claude/) | OAuth flow; `claude mcp add --transport http slack https://mcp.slack.com/mcp` |
| **korotovsky/slack-mcp-server** | MCP (open-source) | [GitHub](https://github.com/korotovsky/slack-mcp-server) | Supports OAuth or stealth mode; stdio/SSE/HTTP transports. Very popular (9,000+ users). |
| **HartreeWorks Claude Skill: Slack** | Claude Skill | [GitHub](https://github.com/HartreeWorks/claude-skill--slack) / [Post](https://wow.pjh.is/journal/claude-skill-slack) | Read/post messages, automate digests. Lightweight skill file. |
| **Composio Slack MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/slack/framework/claude-code) | Composio account required; structured access to messages, channels, files. |

---

## Google Workspace (Gmail, Drive, Calendar, Docs, Sheets)

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Hardened Google Workspace MCP** | MCP (open-source) | [GitHub](https://github.com/c0webster/hardened-google-workspace-mcp) / [Original](https://github.com/taylorwilsdon/google_workspace_mcp) / [Post](https://wow.pjh.is/journal/claude-code-google-workspace-mcp) | Google Cloud OAuth credentials. 20+ tools for Gmail, Drive, Calendar, Docs, Sheets. Already in tools.md. |

---

## Asana

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Asana Official MCP (V2)** | MCP (remote) | [Asana Docs](https://developers.asana.com/docs/using-asanas-mcp-server) / [Integration Guide](https://developers.asana.com/docs/integrating-with-asanas-mcp-server) | `claude mcp add --transport sse asana https://mcp.asana.com/sse` — OAuth flow. Note: V1 deprecated, shuts down May 2026. |
| **@roychri/mcp-server-asana** | MCP (open-source) | [GitHub](https://github.com/roychri/mcp-server-asana) | `claude mcp add asana -e ASANA_ACCESS_TOKEN=<TOKEN> -- npx -y @roychri/mcp-server-asana` — personal access token. |
| **Composio Asana MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/asana/framework/claude-code) | Composio account; create tasks, manage projects, tag work. |

---

## Notion

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Notion Official Hosted MCP** | MCP (remote) | [Notion Docs](https://developers.notion.com/docs/mcp) / [Blog](https://www.notion.com/blog/notions-hosted-mcp-server-an-inside-look) | `claude mcp add --transport http notion https://mcp.notion.com/mcp` — OAuth flow. Token-efficient Markdown API. |
| **Notion Plugin for Claude Code** | Plugin | [GitHub](https://github.com/makenotion/claude-code-notion-plugin) | Bundles Notion Skills + MCP server + slash commands. One-click install. |
| **makenotion/notion-mcp-server** | MCP (open-source) | [GitHub](https://github.com/makenotion/notion-mcp-server) | Self-hosted; requires Notion API integration token. |
| **Composio Notion MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/notion/framework/claude-code) | Composio account required. |

---

## QuickBooks Online

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Intuit x Anthropic Partnership** | Official (coming spring 2026) | [Intuit Press Release](https://investors.intuit.com/news-events/press-releases/detail/1305/intuit-and-anthropic-partner-to-bring-trusted-financial-intelligence-and-custom-ai-agents-to-consumers-and-businesses) | Native integration coming to Claude.ai, Cowork, Claude for Enterprise. |
| **nikhilgy/quickbooks-mcp-server** | MCP (open-source) | [GitHub](https://github.com/nikhilgy/quickbooks-mcp-server) | QuickBooks API OAuth credentials. Certified by MCP Review. |
| **CData QuickBooks MCP Server** | MCP (commercial) | [CData](https://www.cdata.com/drivers/quickbooks/mcp/) / [GitHub (read-only)](https://github.com/CDataSoftware/quickbooks-mcp-server-by-cdata) | CData license; read-only free version on GitHub. Full CRUD via paid server. |
| **Composio QuickBooks MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/quickbooks/framework/claude-agents-sdk) | Composio account; manage customers, reports, accounts. |
| **Zapier MCP (QuickBooks actions)** | MCP (via Zapier) | [Zapier](https://zapier.com) / [Claude Connector](https://www.claude.com/connectors/zapier) | Zapier account; connect QuickBooks actions via Zapier's 30,000+ integrations. |

---

## Xero

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **XeroAPI/xero-mcp-server** (Official) | MCP (open-source) | [GitHub](https://github.com/XeroAPI/xero-mcp-server) | Xero OAuth 2.0 app (CLIENT_ID + CLIENT_SECRET). ~40 commands: invoices, P&L, contacts, etc. Needs custom app subscription (~$5/mo). |
| **Composio Xero MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/xero/framework/claude-code) | Composio account required. |
| **CData Xero MCP Server** | MCP (commercial) | [CData](https://www.cdata.com/drivers/xero/mcp/) | CData license for real-time connections. |
| **Claude Skill: Bookkeeping (Xero)** | Claude Skill | [Post](https://wow.pjh.is/journal/claude-code-does-my-bookkeeping) | Uses Xero API to reconcile transactions, manage balance sheets. Already in tools.md. |
| **Claude Skill: Send Invoices (Xero + Toggl)** | Claude Skill | [Post](https://wow.pjh.is/journal/claude-skill-send-my-invoices) | Pulls hours from Toggl, creates invoices in Xero, emails via Gmail. Already in tools.md. |

---

## Expensify

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Zapier MCP for Expensify** | MCP (via Zapier) | [Zapier](https://zapier.com/mcp/expensify) | Zapier account; create expense reports, export to PDF. Uses 2 Zapier tasks per MCP call. |
| **viaSocket MCP for Expensify** | MCP (via viaSocket) | [viaSocket](https://viasocket.com/mcp/expensify) | viaSocket account; handles auth, API limits, and security. |

*No dedicated standalone Expensify MCP server exists yet. Zapier or viaSocket are the best routes.*

---

## Deel

*No dedicated Deel MCP server found as of March 2026.* Options:

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Zapier (Deel actions)** | Automation | [Zapier](https://zapier.com) | Connect Deel via Zapier's pre-built integrations; accessible via Zapier MCP. |
| **Custom MCP server** | DIY | [Deel API Docs](https://developer.deel.com/) / [MCP SDK](https://github.com/modelcontextprotocol/servers) | Build a custom MCP server wrapping Deel's REST API. |

---

## Gusto

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Gusto Official MCP Server** | MCP (official) | [Gusto Docs](https://docs.gusto.com/app-integrations/docs/mcp) | Official MCP server. Query payroll, new hires, compensation, contractors via natural language. Test with demo companies first. |

---

## Greenhouse (Hiring / ATS)

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **senorllama/greenhouse-mcp** | MCP (open-source) | [LobeHub](https://lobehub.com/mcp/senorllama-greenhouse-mcp) | OAuth2 credentials (GREENHOUSE_CLIENT_ID + SECRET). Wraps Greenhouse Harvest v3 API. |
| **alexmeckes/greenhouse-mcp** | MCP (open-source) | [GitHub](https://github.com/alexmeckes/greenhouse-mcp) | GREENHOUSE_API_KEY env var. List jobs, search candidates, advance applications. |
| **Zapier MCP (Greenhouse actions)** | MCP (via Zapier) | [Zapier](https://zapier.com/mcp/greenhouse) | Zapier account; 30,000+ actions available. |

---

## Airtable

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Airtable Official MCP Server** | MCP (remote) | [Airtable Docs](https://support.airtable.com/docs/using-the-airtable-mcp-server) | `claude mcp add --transport http airtable https://mcp.airtable.com/mcp --header "Authorization: Bearer [TOKEN]"` — personal access token. |
| **domdomegg/airtable-mcp-server** | MCP (open-source) | [GitHub](https://github.com/domdomegg/airtable-mcp-server) | `claude mcp add --transport stdio --env AIRTABLE_API_KEY=KEY airtable -- npx -y airtable-mcp-server` |
| **felores/airtable-mcp** | MCP (open-source) | [GitHub](https://github.com/felores/airtable-mcp) | Full CRUD; specialized for staged table building with Claude. |
| **Composio Airtable MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/airtable/framework/claude-code) | Composio account required. |

---

## Zoom

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **echelon-ai-labs/zoom-mcp** | MCP (open-source) | [GitHub](https://github.com/echelon-ai-labs/zoom-mcp) | Server-to-Server OAuth 2.0. Create/manage meetings, access data. |
| **@sweatco/zoom-mcp** | MCP (open-source) | [LobeHub](https://lobehub.com/mcp/sweatco-zoom-mcp) | Zoom OAuth app. Access meeting transcripts and AI summaries. Needs Google Cloud for proxy. |
| **Prathamesh0901/zoom-mcp-server** | MCP (open-source) | [GitHub](https://github.com/Prathamesh0901/zoom-mcp-server) | Create, update, delete, retrieve meetings via MCP. |
| **Composio Zoom MCP** | MCP (via Composio) | [Composio](https://composio.dev/toolkits/zoom/framework/claude-agents-sdk) | Composio account required. |

---

## Every.org (Donation Pages)

*No dedicated Every.org MCP server exists yet.* Options:

| Option | Type | Link | Setup |
|--------|------|------|-------|
| **Every.org Charity API** | REST API (free) | [Every.org API](https://www.every.org/charity-api) / [Docs](https://docs.every.org/docs/intro) | Free for non-commercial use. Search 1M+ nonprofits, create fundraisers, donation webhooks. Could wrap in custom MCP. |
| **Benevity Nonprofit MCP** | MCP (related) | [Benevity Docs](https://causeshelp.benevity.org/hc/en-us/articles/43364091494164-Benevity-nonprofit-MCP-server) | Discover and donate to nonprofits via Claude. Different platform but similar use case. |
| **briancasteel/charity-mcp-server** | MCP (open-source) | [GitHub](https://github.com/briancasteel/charity-mcp-server) | Look up charity info, verify tax-deductible status, search nonprofits. |

---

## Cross-Tool Connectors

These platforms let you connect *any* of the above tools to Claude via a single MCP integration:

| Platform | Link | Notes |
|----------|------|-------|
| **Zapier MCP** | [zapier.com](https://zapier.com) / [Claude Connector](https://www.claude.com/connectors/zapier) | 30,000+ actions across all major tools. 2 Zapier tasks per MCP call. |
| **Composio** | [composio.dev](https://composio.dev) | MCP server implementations for 100+ tools. Handles auth and security. |
| **viaSocket** | [viasocket.com](https://viasocket.com) | MCP servers for many integrations; handles auth and rate limits. |
| **Activepieces** | [activepieces.com](https://www.activepieces.com) | Free, open-source; MCP servers for Xero, Airtable, QuickBooks, and more. |
