---
name: integrate-posthog
description: Integrate or upgrade PostHog analytics and observability across browser, backend, serverless, and AI applications. Use for instrumentation, identity, replay, first-party ingestion, delivery reliability, dashboards, and operational alerts.
---

# Integrate PostHog

Implement production-ready observability adapted to the repository. For an upgrade, preserve working instrumentation and limit changes to the requested surfaces; for a full integration, account for every applicable surface below. Prefer current official PostHog SDKs and guidance over copied framework snippets.

## 1. Establish the contract

1. Read the repository instructions and inspect its package managers, frontend, backend, authentication, AI providers, runtime lifecycle, infrastructure, deployment, CSP, and existing telemetry.
2. Locate the supplied PostHog project token in the request or environment. Accept a public `phc_` ingestion token. Treat any `phx_` personal API key as privileged server-only configuration, never as the browser token.
3. Determine the PostHog region and ingestion/UI hosts from project configuration. Request the missing value only when choosing incorrectly would send data to another region.
4. Consult the current official PostHog documentation for every detected framework, SDK, and runtime before choosing integration points.

Finish when each in-scope surface has an implementation location, or a recorded reason it does not apply. Dashboard mutations, alert subscriptions, and production probes require appropriate access and authorization; missing access becomes a specific handoff, not permission to expand scope.

## 2. Design the telemetry

Preserve existing event contracts; use a compact `object_action` taxonomy for new events. Distinguish user intent, server acceptance, terminal outcome, and user-visible completion where these can fail independently. For asynchronous work, carry an opaque operation ID through these milestones, plus attempt IDs when retries need separate measurement; keep breakdown properties low-cardinality.

Use one trusted internal auth ID across browser events, backend events, errors, replays, and AI traces; mutable email is a person property, not a join key. Carry the anonymous browser identity into backend events before authentication. Keep sampled funnels distinct from complete operational counts.

Route feature code through a typed analytics boundary. Make capture and flush failures non-fatal, bound delivery waits to the product's latency budget, and surface failures through bounded structured logs. Strip credentials, authorization headers, and raw secret values from telemetry payloads and diagnostic logs.

Finish with event producers, correlation keys, canonical properties, and populations defined for each measured journey.

## 3. Implement browser coverage

When a browser is in scope, read [Browser lifecycle](references/browser-lifecycle.md) before implementing identity, redirect delivery, and exception ownership.

Initialize one fully enabled browser client at the earliest framework-supported application root with PostHog's current recommended defaults. Enable autocapture, route-aware pageviews/page leaves, session replay, heatmaps, dead-click detection, performance/Web Vitals, automatic exceptions, and explicit framework error-boundary capture. Assign one owner per automatic event to avoid duplicates.

Run full capture immediately. Do not add consent gating or a cookie banner.

Finish when the applicable lifecycle checks in the reference pass and the enabled browser products deliver events.

## 4. Add first-party ingestion

When browser ingestion is in scope, route PostHog ingestion and required assets through a same-origin path or subdomain supported by the existing hosting layer before production. Point the browser SDK's `api_host` at it and keep `ui_host` pointed at the correct PostHog app region.

Forward only required methods, paths, query strings, bodies, and headers. Preserve client attribution where the trusted hosting boundary supplies it. Exclude the proxy path from authentication, localization, redirects, caching rules that break ingestion, and application middleware. Update CSP for SDK workers and any resources not served through the proxy.

Verify event and asset delivery through the actual hosting path; a local rewrite passing is not proof that the deployed adapter supports it.

## 5. Add server coverage

When server code exists:

- use the official runtime-appropriate SDK behind a singleton or lifecycle-owned wrapper;
- attach the same identity/correlation keys plus consistent `service`, `runtime`, and `environment` properties;
- capture important server-confirmed business outcomes, including background jobs and webhooks where applicable;
- cover outer request/job boundaries as well as caught failures returned as error responses; keep one exception owner per failure;
- flush and shut down cleanly in long-lived processes;
- use the SDK's runtime-supported immediate delivery or awaited flush/shutdown for short-lived runtimes, including early returns and failure paths.

Attribute location using the client IP supplied by a trusted hosting boundary. Otherwise disable GeoIP so the datacenter is not mistaken for the user. Webhook/provider IPs are not user IPs.

Verify boundary coverage across in-scope routes/workers and assert delivery before termination without changing business outcomes when PostHog is unavailable.

## 6. Add AI observability

When the product calls LLM or embedding APIs, use PostHog's official provider wrapper where available. Trace generations and embeddings, with spans for material stages such as retrieval, tool calls, and retries. Carry an operation trace ID through concurrent/background stages and a session ID through conversations; link user/replay identities where supported.

Capture inputs, outputs, model, usage, cost, latency, time to first token where available, and errors with useful diagnostic context. Include tool inputs/results and intermediate stage outputs where supported.

Verify emitted payloads include generation content and trace linkage, and prove the provider call still works when telemetry is disabled or fails.

## 7. Turn telemetry into monitoring

For a full integration, create or update saved funnels/dashboards for the core journey and actionable operational alerts. For a targeted upgrade, update the monitors affected by the changed event contract. Use existing acquisition dimensions to expose meaningful drop-offs rather than inventing product-specific dashboards.

- Pair starts with expected terminal outcomes. Where server success can fail to reach the user, monitor user-visible completion separately. Use operation-level correlation for job reliability; a person-level funnel alone can join unrelated attempts.
- Define each metric's population, denominator, environment, time window, and expected delay. Account for sampling, retries, ingestion lag, and normal abandonment before labeling missing events as failures.
- Choose thresholds and minimum volumes from traffic and failure impact; give every alert an owner and response. Check current alert-type support, metric semantics, evaluation windows, and project limits instead of copying fixed values.
- Keep managed definitions reproducible using repository conventions, with dry-run previews and idempotent updates that preserve unrelated dashboard/alert resources. Separate production metrics from test probes. Use a scoped test alert or test environment to prove notification delivery.

Finish with verified queries, alert evaluation, and an authorized notification test, or an explicit pending item naming the missing access, owner/decision, and verification step. Event ingestion alone is not operational monitoring.

## 8. Configure and prove delivery

1. Add documented environment placeholders, deployment bindings/secrets, proxy infrastructure, and source-map upload using repository conventions. The browser `phc_` token is public configuration; privileged management keys remain secret.
2. Add focused tests for the applicable checks above: serialized payloads/secret filtering, proxy routing, failure isolation and time bounds, exception ownership, terminal-event correlation, and runtime delivery. Exercise the browser lifecycle reference and AI trace propagation when applicable.
3. Run the repository's complete relevant lint, formatting, type-check, test, build, and infrastructure validation commands; repair integration-caused failures.
4. Perform authorized, synthetic end-to-end probes when configuration permits. Inspect received events, replays, exceptions, and AI traces for correct region, identity/GeoIP, correlation, diagnostic content, and secret filtering—not merely event presence. Include a failing path and a user-visible successful outcome.
5. Report changed files, configuration names, event contracts, proxy route, monitor links or definitions, verification evidence, and specific external handoffs. Distinguish code complete from live delivery and notification verification.

Completion requires every in-scope surface to be implemented and every locally verifiable check to pass; external verification gaps remain explicitly pending. A package installation or isolated `capture()` call alone is incomplete.
