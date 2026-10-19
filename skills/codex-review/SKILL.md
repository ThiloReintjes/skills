---
name: codex-review
description: Codex review loop on gpt-6.1-sol via the local CLIProxyAPI. Optional simplify pass, then review, validate, and fix until no P0–P2 findings remain. Use when the user asks for a Codex review or a review loop.
---

# Codex review loop

Codex reviews, you judge and fix. A **round** is one fresh Codex review of the whole
change, followed by your verdict on every finding and the fixes. The loop ends on a
**clean** round: no P0, P1, or P2 finding you accept.

## 1. Pin the change

- **Base**: the ref the user named, otherwise `origin/<default branch>` after a fetch.
  `git rev-parse <base>` must resolve and the change against it must be non-empty.
- **Scope**: what the change is meant to do, and what was deliberately left out, as
  two short lists taken from the conversation, the PR body, or the issue. Codex
  treats this as the spec; without the out-of-scope list it reports requirements
  nobody agreed to. If neither the conversation nor the PR states a scope, ask.
- **Focus**: risks particular to this change. For guards (hooks, permission checks,
  release gates), ask for bypasses and for errors that let the guard pass.

Done when the base resolves, the change is non-empty, and both scope lists exist.

## 2. Simplify (only when asked)

When the invocation asks for it (for example `/codex-review simplify`), run the
`code-simplifier` skill on the change, then the repo's checks, before the first
round. Clean-up then happens once instead of costing review rounds.

## 3. Run a round

Write the prompt below to a new file in the scratchpad for each round, then run
`run-codex.sh` from this skill's folder in the background (a round takes several
minutes):

```bash
<skill-dir>/run-codex.sh <repo-dir> <prompt-file> <output-file>
```

The script reads the proxy key, checks the proxy, and runs `codex exec` read-only in a new session, so every round starts without memory of the last.

```text
Review a change in this repository. Do not edit files.

The change is all work since <base>, committed or not: `git diff $(git merge-base <base> HEAD)`,
plus untracked files from `git status --short`.

Intended scope:
- <...>
Out of scope, do not report as missing:
- <...>
Focus:
- <...>

Method: apply the Standards and Spec axes of ~/.agents/skills/code-review/SKILL.md,
smell baseline included. Skip its sub-agent, issue-tracker, and aggregation steps; the
scope above is the spec, and the standards are AGENTS.md, CLAUDE.md, and the docs they
name. Confirm each finding against the surrounding code before reporting it.

Already considered and rejected; raise again only with new evidence:
- <finding>: <reason>

Report each finding on its own line:
[P0|P1|P2|P3] <file>:<line> <problem>. Failure: <concrete input or state -> wrong result>. Fix: <one line>.
P0 breaks production, data, or security. P1 is a bug on a likely path. P2 is a bug on an
edge path or a clear standards breach. P3 is polish.
End with `Highest: P<n>` or `Highest: none`.
```

## 4. Judge every finding

Each finding is a claim. Read the code it names, reproduce it when that is cheap, and
give it a verdict: **accept**, or **reject** with a one-line reason (outside the scope,
already handled, failure cannot happen). Codex sees only the repo; you also know the
conversation, so the verdict is yours.

Done when every finding has a verdict.

## 5. Fix, then the next round

Fix every accepted P0–P2 finding, with a regression test where the repo's test setup
supports one, and run the checks the repo's AGENTS.md names. Then run the next round
on the whole change, since fixes bring their own bugs, and carry every rejected
finding into its prompt so the loop converges.

Stop on a clean round. After five rounds without one, stop and show the user what is
still open.

## 6. Report

Per round: accepted findings and their fixes, rejected findings and why. Then the open
P3 findings, left unfixed for the user to decide, and the result of the last checks.

## Troubleshooting

- "not supported when using Codex with a ChatGPT account": the call went past the
  proxy. Run reviews through `run-codex.sh`.
- `codex review --base` accepts no instructions, so scope and verdicts cannot reach it.
  This skill uses `codex exec` for that reason.
- MCP authentication errors in the `.log` file are noise; the review still runs.
