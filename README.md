# Agent skills

My public collection of reusable agent skills. Each skill lives in its own folder under `skills/` and can be installed independently.

## Available skills

### `integrate-posthog`

Add production-ready PostHog analytics and observability to web, full-stack, serverless, edge, and AI applications. It covers stack discovery, browser and backend instrumentation, identity continuity, first-party ingestion, session replay, error tracking, performance monitoring, AI traces, deployment configuration, and verification.

## Install

Clone this repository, then copy the skill you want into your agent's personal skills directory.

Codex:

```sh
mkdir -p ~/.codex/skills
cp -R skills/integrate-posthog ~/.codex/skills/
```

Claude Code:

```sh
mkdir -p ~/.claude/skills
cp -R skills/integrate-posthog ~/.claude/skills/
```

Invoke it with a PostHog public project token:

```text
Use $integrate-posthog to add full PostHog analytics to this project with the project token <POSTHOG_PROJECT_API_KEY>.
```

`<POSTHOG_PROJECT_API_KEY>` must be the project's public `phc_` ingestion token, not a privileged `phx_` personal API key.

## License

MIT
