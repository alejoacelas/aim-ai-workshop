# helpme-worker

Cloudflare Worker that powers the `helpme` CLI tool. Receives command output, analyzes it with Gemini Flash via OpenRouter, and returns plain-English explanations.

## Redeployment

After any code change, you must deploy **and then re-set the API key secret** (the secret doesn't survive deploys):

```bash
cd helpme-worker
npx wrangler deploy
```

Then immediately re-set the secret:

```bash
eval "$(grep OPENROUTER_API_KEY /Users/alejo/code/cliver/dev/.env)" && echo "$OPENROUTER_API_KEY" | npx wrangler secret put OPENROUTER_API_KEY --name helpme-worker
```

Wait a few seconds after setting the secret before testing.

## D1 database

If you need to reset or update the schema:

```bash
npx wrangler d1 execute helpme-errors --remote --file=schema.sql
```

## Endpoints

- `POST /analyze` — analyze command output, returns `{ ok, explanation, fix_commands }`
- `GET /logs` — HTML dashboard of all logged errors

## Testing

```bash
# Error case
curl -s -X POST https://helpme-worker.alejoacelas.workers.dev/analyze \
  -H 'Content-Type: application/json' \
  -d '{"command":"brew install git","stdout":"","stderr":"Error: command not found: brew","exit_code":127,"os":"darwin","shell":"zsh","log_history":[]}' | jq .

# Success case
curl -s -X POST https://helpme-worker.alejoacelas.workers.dev/analyze \
  -H 'Content-Type: application/json' \
  -d '{"command":"echo hello","stdout":"hello\n","stderr":"","exit_code":0,"os":"darwin","shell":"zsh","log_history":[]}' | jq .
```
