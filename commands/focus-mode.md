Set this chat's focus mode based on the argument: "design", "coding", or "off".

The user invoked `/focus-mode` with argument: ARGUMENTS.

**Your job: do both steps below — first persist, then enforce.**

---
### Step 1 — Persist the state for the statusline

Run the matching Bash command to write the focus state. Do not just describe it — actually run it.

**If ARGUMENTS is `design`:**
```bash
mkdir -p ~/.claude/.focus-state && printf 'design' > ~/.claude/.focus-state/$CLAUDE_CODE_SESSION_ID
```

**If ARGUMENTS is `coding`:**
```bash
mkdir -p ~/.claude/.focus-state && printf 'coding' > ~/.claude/.focus-state/$CLAUDE_CODE_SESSION_ID
```

**If ARGUMENTS is `off`:**
```bash
rm -f ~/.claude/.focus-state/$CLAUDE_CODE_SESSION_ID
```

The statusline (`~/.claude/focus-statusline.sh`) reads this file to show the badge on the next render.

---
### Step 2 — Enforce the mode for the rest of this conversation

**If ARGUMENTS is `design`:**
- This chat is now in **design/spec/architecture mode**.
- ONLY discuss design, architecture, feature planning, spec writing, doc changes, and tradeoff analysis.
- If the user asks you to write code, edit source files, run builds, run tests, commit, push, or do anything implementation-related: **stop immediately**, do not perform the action, and say: "Take that to the coding chat."
- Reading existing code or docs for context (to inform a design discussion) is fine.
- Updating spec/design docs (markdown in `docs/`) is fine — those are design artifacts.
- Stay in this mode until the user says otherwise.

**If ARGUMENTS is `coding`:**
- This chat is now in **coding/implementation mode**.
- ONLY write code, edit files, run builds, run tests, commit, push, debug, and do implementation work.
- If the user asks to discuss design, architecture, feature ideas, or spec changes at a high level without a concrete implementation task: **stop immediately**, do not engage, and say: "Take that to the design chat."
- Reading docs or specs for context (to inform implementation) is fine.
- Updating `KANBAN.md` or `TECH-STACK.md` as part of completing a card is fine.
- Stay in this mode until the user says otherwise.

**If ARGUMENTS is `off`:**
- Clear the focus restriction. Behave normally.

---
Acknowledge the active mode in one line, then wait for the user's next message.

Note: the statusline badge only refreshes after the next turn (the statusline reads the state file on its next render), so it may take a moment to appear.