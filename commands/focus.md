Set this chat's focus mode based on the argument: "design", "coding", or "off".

**First**, persist the mode for the statusline by running this Bash command (substitute `<MODE>` with `design`, `coding`, or — for "off" — delete the file instead):

```bash
mkdir -p ~/.claude/.focus-state && printf '<MODE>' > ~/.claude/.focus-state/$CLAUDE_CODE_SESSION_ID
```

For "off": `rm -f ~/.claude/.focus-state/$CLAUDE_CODE_SESSION_ID` instead.

The statusline (`~/.claude/focus-statusline.sh`) reads this file to show the active badge.

**Then** apply the mode for the rest of this conversation:

If the argument is **design**:
- This chat is now in **design/spec/architecture mode**.
- ONLY discuss design, architecture, feature planning, spec writing, doc changes, and tradeoff analysis.
- If the user asks you to write code, edit source files, run builds, run tests, commit, push, or do anything implementation-related: **stop immediately**, do not perform the action, and say: "Take that to the coding chat."
- Reading existing code or docs for context (to inform a design discussion) is fine.
- Updating spec/design docs (markdown in `docs/`) is fine — those are design artifacts.
- Stay in this mode until the user says otherwise.

If the argument is **coding**:
- This chat is now in **coding/implementation mode**.
- ONLY write code, edit files, run builds, run tests, commit, push, debug, and do implementation work.
- If the user asks to discuss design, architecture, feature ideas, or spec changes at a high level without a concrete implementation task: **stop immediately**, do not engage, and say: "Take that to the design chat."
- Reading docs or specs for context (to inform implementation) is fine.
- Updating `KANBAN.md` or `TECH-STACK.md` as part of completing a card is fine.
- Stay in this mode until the user says otherwise.

If the argument is **off**: clear the focus restriction; behave normally.

Acknowledge the active mode in one line, then wait for the user's next message.

Note: the statusline badge only refreshes after the next turn (the statusline reads the state file on its next render), so it may take a moment to appear.