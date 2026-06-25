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

```bash
cp commands/focus.md ~/.claude/commands/focus.md
```

That's enough to use `/focus`. The statusline badge is optional.

### 2. (Optional) Add the statusline badge

Copy the statusline script and wire it up in your Claude Code settings:

```bash
cp focus-statusline.sh ~/.claude/focus-statusline.sh
chmod +x ~/.claude/focus-statusline.sh
```

Then point Claude Code at it in `~/.claude/settings.json`:

```json
{
  "statusCommand": "~/.claude/focus-statusline.sh"
}
```

> **Note:** `focus-statusline.sh` is written to also render the [ponytail](https://github.com/flamfoof/ponytail) statusline segment if you have that plugin installed. If you don't use ponytail, the badge still works — ponytail's segment is just skipped silently.

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

**2. `focus-statusline.sh`** — add a `case` arm for the new mode name:

```bash
case "$mode" in
  design) badge=$'\033[1;36m\xF0\x9F\x8E\xA8 FOCUS:DESIGN\033[0m' ;;
  coding) badge=$'\033[1;33m\xE2\x9A\x99 FOCUS:CODING\033[0m'  ;;
  review) badge=$'\033[1;35m\xF0\x9F\x94\x8D FOCUS:REVIEW\033[0m' ;;  # ← new
  *)      badge=$'\033[90m\xE2\x97\x8B FOCUS:none\033[0m'      ;;
esac
```

Pick any ANSI color and emoji. The state file mechanism requires no changes — it just writes whatever word you pass as the argument.

**3. The skill description line** (first line of `commands/focus.md`) — update it to list the new argument so Claude Code's autocomplete shows it.

---

## File layout

```
commands/
  focus.md          ← the skill (drop into ~/.claude/commands/)
focus-statusline.sh ← optional statusline badge
```

---

## License

MIT