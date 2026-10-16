# Review Mindmap and Traversal Order

When evaluating a pull request, reviewers must follow this cognitive hierarchy. Do not inspect low-level style before validating high-level security and correctness.

```
                    ┌─────────────────────────┐
                    │ 1. PR Hygiene & Triage  │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 2. Security & Secrets   │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 3. API & Data Contracts │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 4. Error & Edge Cases   │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 5. Persistence & Concur │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 6. Observability & Logs │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 7. Tests & Scenarios    │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ 8. Naming & Micro-Nits  │
                    └─────────────────────────┘
```

## Detailed Stage Checkpoints

1. **PR Hygiene & Triage (PRC)**
   - Does CI pipeline pass? Are build failures caused by the diff or existing flaky tests?
   - Is the pull request scoped to a single logical change?

2. **Security & Secrets (SEC)**
   - Are any API keys, credentials, or secrets exposed in code or config?
   - Is all external input treated as untrusted and properly validated?
   - Are PII fields properly annotated or masked from loggers?
   - Are authorization annotations present on all new controller methods?

3. **API & Data Contracts (API / STR)**
   - Do response bodies maintain backwards compatibility with existing clients?
   - Are required fields properly guarded?
   - Do cross-repo message definitions match upstream schemas?

4. **Error & Edge Cases (ERR)**
   - Are exceptions caught, logged, and propagated cleanly?
   - Are promises or asynchronous tasks protected against unhandled rejections?
   - Are network requests wrapped in timeouts and retry backoff?

5. **Persistence & Concurrency (DB)**
   - Are database queries indexed? Are there any N+1 query loops?
   - Are transactional boundaries scoped properly without holding connection locks across slow HTTP calls?

6. **Observability & Logs (OBS)**
   - Are error paths logged with relevant context (orderId, tenantId)?
   - Are sensitive credentials or auth headers omitted from trace logs?

7. **Tests & Scenarios (TST / BDD)**
   - Are new edge cases covered by unit tests?
   - Do Cucumber/Gherkin features test real user behavior or implementation trivia?

8. **Naming & Micro-Nits (NAM)**
   - Do variable and method names reflect domain reality?
   - Flag as `nit` only; never block a release for naming.
