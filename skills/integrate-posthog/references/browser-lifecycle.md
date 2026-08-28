# Browser lifecycle

Apply the branches supported by the application and requested scope. Use the installed SDK's documented APIs; these are behavioral requirements, not framework-specific snippets.

## Authenticated identity transitions

Build identity from the authoritative auth source. Use the SDK's supported anonymous-to-identified flow. Treat identity synchronization as transitions, not just a login callback:

| Transition | Required behavior |
|---|---|
| Anonymous → user A | Identify A as soon as authentication resolves, preserving anonymous history. |
| A → same A, changed profile | Update mutable person properties, including removal and verification changes. |
| A → user B without logout | Reset A's analytics identity before identifying B. |
| A → signed out | Reset identity and any cached synchronization state. |
| Login before SDK readiness | Retry current identity when the SDK becomes available. |

Observe profile changes even when the UID stays the same. Suppress redundant updates using the identity plus relevant properties, not UID alone. Keep email out of join keys and avoid treating form inputs or untrusted webhook metadata as ownership proof.

Test the applicable transitions and emitted properties, including explicit clearing of removed attributes and direct account switches. An attempted identify while capture is unavailable must not mark synchronization complete.

## Intent before navigation

For actions that redirect, unload, or hand off to an external provider, capture intent before fallible prerequisites when intent is what the event measures. Keep server acceptance and completion as separate authoritative outcomes. Use SDK-supported immediate, navigation-safe delivery, such as beacon transport where supported; default batching can lose the last event before a redirect.

Verify receipt under immediate navigation and slow/failing prerequisites. Analytics errors and delivery waits must not prevent the underlying action or invalidate a successful provider response. Do not treat a queued beacon as proof that the event arrived.

## Exceptions before and outside rendering

Install exception capture early enough to cover startup failures. Verify when automatic SDK observers become active; if asynchronous setup leaves a gap, use supported early listeners or buffering. Cover uncaught errors, unhandled rejections, and framework render boundaries that do not reach global listeners.

Choose one capture owner for overlapping automatic listeners, manual listeners, and error boundaries. Deduplicate the same failure without suppressing genuinely separate occurrences. Verify initialization idempotency, route pageview uniqueness, early startup errors, rejected promises, and render failures. Tag synthetic probes and exclude them from normal incident alerts while keeping their delivery inspectable.
