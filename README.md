# claude-chat-focus

A [Claude Code](https://claude.ai/code) skill that locks a chat session to a single mode — design/architecture or coding/implementation — so context doesn't bleed between the two.

When design mode is active, any coding request gets bounced: *"Take that to the coding chat."*  
When coding mode is active, high-level architecture discussions get the same treatment.

An optional statusline badge shows the active mode in your terminal.

---

## How it works

The skill writes a one-word state file per session:

```
~/.claude/.focus-state/<session_id>
```

Claude reads that on activation and enforces the matching rules for the rest of the conversation. The statusline script reads the same file to render a badge.

---

## Installation

### 1. Add the skill

Copy `commands/focus.md` into your Claude Code commands directory:

**macOS / Linux / WSL:**
```bash
cp commands/focus.md ~/.claude/commands/focus.md
```

**Windows (PowerShell):**
```powershell
copy commands\focus.md $env:USERPROFILE\.claude\commands\focus.md
```

That's enough to use `/focus`. The statusline badge is optional.

### 2. (Optional) Add the statusline badge

Pick the script for your platform, copy it, then wire it up in `~/.claude/settings.json`.

**macOS / Linux / WSL — `focus-statusline.sh`:**
```bash
cp focus-statusline.sh ~/.claude/focus-statusline.sh
chmod +x ~/.claude/focus-statusline.sh
```

**Windows — `focus-statusline.ps1`:**
```powershell
copy focus-statusline.ps1 $env:USERPROFILE\.claude\focus-statusline.ps1
```

**Both platforms** — add to `~/.claude/settings.json` (or `%USERPROFILE%\.claude\settings.json` on Windows):

```json
{
  "statusCommand": "focus-statusline"
}
```

> **Why `"focus-statusline"` without a path?** Claude Code looks up bare names in its own directory (`~/.claude/`), so the file resolves automatically on both platforms. Replace with the absolute path if it doesn't.
>
> Both scripts also render the [ponytail](https://github.com/flamfoof/ponytail) statusline badge when that plugin is installed — skipped silently if absent.

---

## Usage

In any Claude Code chat, run:

| Command | Effect |
|---|---|
| `/focus design` | Lock to design/architecture only |
| `/focus coding` | Lock to coding/implementation only |
| `/focus off` | Clear — behave normally |

Claude acknowledges the mode in one line, then enforces it for the rest of the session.

---

## Modes

### `design`
- Discusses architecture, specs, tradeoffs, feature planning, doc changes.
- Refuses to write code, edit source files, run builds/tests, commit, or push.
- Reading existing code **for context** is fine.
- Updating markdown docs in `docs/` is fine (design artifacts).

### `coding`
- Writes code, edits files, runs builds/tests, commits, pushes, debugs.
- Refuses high-level design or architecture discussions without a concrete implementation task.
- Reading specs/docs **for context** is fine.
- Updating `KANBAN.md` / `TECH-STACK.md` as part of completing a card is fine.

### `off`
- Clears the restriction entirely. Normal Claude Code behavior resumes.

---

## Adding new focus modes

The skill is intentionally easy to extend. Three places to touch:

**1. `commands/focus.md`** — add a new `If the argument is **<name>**:` block following the same pattern as `design` and `coding`. Define what the mode allows and what it refuses.

**2. `focus-statusline.sh` / `focus-statusline.ps1`** — add a new branch in both:

**`focus-statusline.sh` (bash):**
```bash
case "$mode" in
  design) badge=$'\033[1;36m🎨 FOCUS:DESIGN\033[0m' ;;
  coding) badge=$'\033[1;33m⚙ FOCUS:CODING\033[0m'  ;;
  review) badge=$'\033[1;35m🔍 FOCUS:REVIEW\033[0m' ;;  # ← new
  *)      badge=$'\033[90m○ FOCUS:none\033[0m'      ;;
esac
```

**`focus-statusline.ps1` (PowerShell):**
```powershell
$badge = switch ($mode) {
  "design" { "${ESC}[1;36m🎨 FOCUS:DESIGN${ESC}[0m" }
  "coding" { "${ESC}[1;33m⚙ FOCUS:CODING${ESC}[0m" }
  "review" { "${ESC}[1;35m🔍 FOCUS:REVIEW${ESC}[0m" }  # ← new
  default  { "${ESC}[90m○ FOCUS:none${ESC}[0m" }
}
```

Pick any ANSI color and emoji. The state file mechanism requires no changes — it just writes whatever word you pass as the argument.

**3. The skill description line** (first line of `commands/focus.md`) — update it to list the new argument so Claude Code's autocomplete shows it.

---

## File layout

```
commands/
  focus.md              ← the skill (drop into ~/.claude/commands/)
focus-statusline.sh     ← optional badge (macOS / Linux / WSL)
focus-statusline.ps1    ← optional badge (Windows / PowerShell)
```

---

## License

MIT