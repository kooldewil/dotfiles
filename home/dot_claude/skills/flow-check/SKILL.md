---
name: flow-check
description: Finds what this session decided, left open, or built that has no durable home yet, and names the command each thread needs next, specs first. Use before clearing or compacting a long session, or when resuming one.
disable-model-invocation: true
---

# Flow check

Adapted from Drewtopia/dotfiles. The conversation is the input. Git, the issue tracker and memory are checked only for items the conversation raised. This skill finds and routes; the user runs the skills it names.

1. List every **item** in this conversation: each decision made, question left open, piece of work done or promised, and term coined. Done when every user request and every agent proposal maps to an item.
2. For each item, find where it is **captured**: pushed commit, PR, tracker issue, ADR, `GLOSSARY.md` entry, or memory file (`~/.claude/memory/` or the project's auto-memory), in whichever repo the item belongs to, not only this project's. Write `uncaptured` only after the lookup ran. Uncommitted or unpushed changes count as local-only, not captured.
3. Group uncaptured items by **thread**. Answer with one table per thread: item, status. Work that exists only on this machine goes first. Then one line of captured items with where each lives, then ask: "Push local-only work?"
4. On yes, commit and push each local-only change the user confirms. Nothing else runs.
5. For each uncaptured thread, name what it needs and the command to type:
   - needs a spec (multi-session work, or open questions): `/grill-with-docs <thread>`, then `/to-spec`, then `/to-tickets`, then `/implement`
   - a term or a lasting decision: `/domain-modeling` records it in `GLOSSARY.md` or an ADR
   - a fact worth remembering across sessions: a memory entry
   - one settled piece of work: `/implement`, or `/tdd` for a small change

   Order the list by risk of loss, then the thread with the most open questions. Finish with a call: continue, clear, or compact — clear when every thread is captured, compact when work continues on the same thread, continue otherwise.
