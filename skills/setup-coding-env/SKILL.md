# Environment Setup

You're setting up a nonprofit founder's machine for a Claude Code workshop. They need Python, Node.js, Git, and Playwright's Chromium browser. Be friendly and clear—most participants have never done anything like this before.

## How to run this

1. **Detect the operating system** — determine macOS, Windows, or Linux. This drives all subsequent commands.

2. **Ask for permission once** — say something like:

   > "I'm going to check what developer tools you have installed and set up anything that's missing. This includes Python, Node.js, Git, and a browser for automation. I'll explain what I'm doing at each step. Sound good?"

   Once they say yes, proceed through all steps without asking again at each one.

3. **Check and install each tool in order.** For each tool, check if it's already installed before attempting installation. Report in plain language:
   - "Checking if Python is installed... already here (v3.13). Moving on."
   - "Node.js isn't installed yet. Installing it now..."

### Step-by-step

#### Package manager
- **macOS:** Check for Homebrew (`brew --version`). If missing, install it: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`. After install, run the shellenv commands Homebrew prints to add it to PATH.
- **Windows:** winget is pre-installed on modern Windows 10/11. Verify with `winget --version`. If unavailable, tell the participant to ask Alejo for help.
- **Linux:** Use the system package manager (apt on Debian/Ubuntu, dnf on Fedora/RHEL). Check which one is available.

#### Python via uv
- Check if `uv` is available (`uv --version`).
- If not installed:
  - **macOS/Linux:** `curl -LsSf https://astral.sh/uv/install.sh | sh` then source the shell profile or add `~/.local/bin` to PATH for the current session.
  - **Windows:** `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
- Then ensure Python 3.13 is available: `uv python install 3.13`
- Verify: `uv run --python 3.13 python --version`

#### Node.js
- Check if Node.js is installed (`node --version`). Version 18+ is fine.
- If not installed:
  - **macOS:** `brew install node`
  - **Windows:** `winget install OpenJS.NodeJS.LTS`
  - **Linux:** Use the system package manager (e.g., `sudo apt install nodejs npm` or install via NodeSource for a newer version)
- Verify: `node --version` and `npm --version`

#### Git
- Check if Git is installed (`git --version`). Usually pre-installed on macOS and Linux.
- If not installed:
  - **macOS:** `xcode-select --install` (installs Git along with command-line tools)
  - **Windows:** `winget install Git.Git`
  - **Linux:** `sudo apt install git` or `sudo dnf install git`
- Verify: `git --version`

#### Playwright Chromium
- Install the Chromium browser binary that Playwright uses: `npx playwright install chromium`
- This pre-downloads the browser so it won't block during the build phase.
- Verify: `npx playwright install --dry-run` should show chromium as already installed.

4. **Set up global Claude Code conventions.** Add a few lines to `~/.claude/CLAUDE.md` (create the file if it doesn't exist). Keep it short — just two rules:
   - Use `uv` for all Python work. Never use bare `pip install`. Use `uv run`, `uv add`, `uv sync` inside projects; for standalone scripts, add PEP 723 inline metadata and run with `uv run script.py`.
   - If the current working directory looks too general (Desktop, Downloads, home folder), create a dedicated project directory first.

5. **Print a summary** at the end. Something like:

```
Setup complete! Here's what you have:

  Python:     ✓ 3.13.x (via uv)
  Node.js:    ✓ 22.x.x
  Git:        ✓ 2.x.x
  Playwright: ✓ Chromium installed

You're ready to go.
```

If any tool failed to install, show it clearly:

```
Setup mostly complete. One issue:

  Python:     ✓ 3.13.x (via uv)
  Node.js:    ✗ Installation failed — ask Alejo for help
  Git:        ✓ 2.x.x
  Playwright: ⏭ Skipped (needs Node.js first)
```

## Important

- **Don't spiral on failures.** If a tool fails to install after one reasonable attempt, stop and say: "This one's being tricky — ask Alejo and he'll help you sort it out."
- **Don't change system settings** beyond what's needed for these tools. No shell customization, no editor config, no dotfile changes beyond what an installer does by default.
- **Be honest about what you're doing.** If you're running a command that modifies the system, say so plainly before you run it.
