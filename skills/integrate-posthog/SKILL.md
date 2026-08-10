---
name: integrate-posthog
description: Integrate or upgrade PostHog across a web, full-stack, serverless, edge, or AI application. Use when adding product analytics, identity tracking, session replay, error tracking, performance monitoring, first-party ingestion, backend events, or AI observability with PostHog.
---

# Integrate PostHog

Implement one production-ready observability path adapted to the repository. Prefer current official PostHog SDKs and guidance over copied framework snippets.

## 1. Establish the contract

1. Read the repository instructions and inspect its package managers, frontend, backend, authentication, AI providers, runtime lifecycle, infrastructure, deployment, CSP, and existing telemetry.
2. Locate the supplied PostHog project token in the request or environment. Accept a public `phc_` ingestion token. Treat any `phx_` personal API key as privileged server-only configuration, never as the browser token.
3. Determine the PostHog region and ingestion/UI hosts from project configuration. Request the missing value only when choosing incorrectly would send data to another region.
4. Consult the current official PostHog documentation for every detected framework, SDK, and runtime before choosing integration points.

Finish when every applicable surface—browser, server, edge/serverless, auth, AI, proxy, deployment, and source maps—has an explicit implementation location or is recorded as not applicable.

## 2. Design the telemetry

Define a compact `object_action` event taxonomy for the product's real acquisition, activation, conversion, retention, and failure journeys. Give each event canonical, low-cardinality properties. Use one stable internal auth ID across browser events, backend events, errors, replays, and AI traces.

Create a typed analytics boundary owned by the observability layer. Route feature code through it instead of scattering SDK configuration or raw capture calls.

## 3. Implement browser coverage

Initialize one fully enabled browser client at the earliest framework-supported application root with PostHog's current recommended defaults. Enable:

- autocapture, route-aware pageviews, and page leaves without duplicates;
- session replay, heatmaps, dead-click detection, and performance/Web Vitals;
- automatic exceptions plus explicit capture from framework error boundaries;
- authenticated-user identification with useful person properties;
- anonymous-to-authenticated history continuity through PostHog's supported identity flow;
- reset on logout.

Run full capture immediately. Do not add consent gating or a cookie banner.

## 4. Add first-party ingestion

Before production, route PostHog ingestion and required assets through a same-origin path or subdomain supported by the existing hosting layer. Point the browser SDK's `api_host` at it and keep `ui_host` pointed at the correct PostHog app region.

Forward only required methods, paths, query strings, bodies, and headers. Preserve client attribution where the trusted hosting boundary supplies it. Exclude the proxy path from authentication, localization, redirects, caching rules that break ingestion, and application middleware. Update CSP for SDK workers and any resources not served through the proxy.

## 5. Add server coverage

When server code exists:

- use the official runtime-appropriate SDK behind a singleton or lifecycle-owned wrapper;
- attach the same distinct ID plus consistent `service`, `runtime`, and `environment` properties;
- capture important server-confirmed business outcomes and handled/unhandled exceptions;
- keep analytics failures from changing product behavior, while exposing delivery failures through bounded structured logs;
- flush and shut down cleanly in long-lived processes;
- use immediate capture or `flushAt: 1`, `flushInterval: 0`, and awaited shutdown as appropriate for short-lived or serverless runtimes.

Attribute location to the client only from a trusted proxy header; otherwise disable GeoIP on server-originated events so the datacenter is not mistaken for the user.

## 6. Add AI observability

When the product calls LLM or embedding APIs, use PostHog's official provider wrapper where available. Trace every generation and embedding, and add spans for retrieval, reranking, tool calls, and other material stages. Carry one trace ID through the operation and one session ID through the conversation; link both to the browser distinct ID and replay session where supported.

Capture inputs, outputs, model, latency, time to first token, usage, cost, and errors. Redact credentials, authorization headers, payment data, raw secret values, and any repository-defined prohibited fields before capture.

## 7. Configure and prove delivery

1. Add documented environment placeholders, deployment bindings/secrets, proxy infrastructure, and source-map upload using repository conventions. The browser `phc_` token is public configuration; privileged management keys remain secret.
2. Add focused tests for initialization idempotency, route pageview uniqueness, identify/reset, anonymous identity continuity, canonical properties, proxy routing, exception capture, and serverless delivery. Cover AI trace/session propagation when applicable.
3. Run the repository's complete relevant lint, formatting, type-check, test, build, and infrastructure validation commands; repair integration-caused failures.
4. Perform a development or production-safe smoke event when configuration permits. Verify browser events, server events, replays, exceptions, and AI traces in PostHog or state precisely which external verification remains.
5. Report changed files, configuration names, events, identity behavior, proxy route, verification results, and any remaining dashboard-side setup.

Completion requires every applicable surface to be implemented and every locally verifiable check to pass. A package installation or isolated `capture()` call alone is incomplete.
