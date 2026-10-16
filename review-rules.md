# Squad Review Rule Catalogue

This catalogue defines the rules enforced by the review lanes. Every rule has a unique ID, detection pattern, mandatory verification command, exemplar comment, and severity weight.

Weights:
- **High**: Raise whenever detected; constitutes a blocker.
- **Medium**: Raise as a risk or probe depending on evidence.
- **Low**: Raise as a nit only.
- **Retired**: Inactive; kept for historical audit log integrity.

---

## 1. Security & Authentication (SEC)

### SEC-001: Plaintext Credentials or Tokens
- **Pattern**: Hardcoded API keys, JWT secrets, passwords, or connection strings in code or config files.
- **Verify**: `grep -En "(password|secret|token|apikey|private_key)\s*[:=]\s*['\"][^'\"]+['\"]" <file>`
- **Exemplar**: `move API secret to environment variable.`
- **Weight**: High

### SEC-002: Missing Method Authorization Guard
- **Pattern**: Public API endpoints or controller handlers missing `@PreAuthorize`, `@HasPermission`, or role check.
- **Verify**: Inspect class and method annotations in controller file.
- **Exemplar**: `endpoint lacks authorization guard. Add @HasPermission.`
- **Weight**: High

### SEC-003: Unsanitized Database Query (SQL Injection)
- **Pattern**: String concatenation used inside SQL or HQL query construction.
- **Verify**: `grep -En "(createQuery|execute|rawQuery)\(.*(\+|\$\{)" <file>`
- **Exemplar**: `use parameterized query to prevent SQL injection.`
- **Weight**: High

### SEC-004: Unmasked PII in Logging
- **Pattern**: Logging raw user objects containing SSN, email, phone, or credit card numbers without masking.
- **Verify**: `grep -En "log\.(info|debug|warn|error)\(.*(user|account|card|ssn)" <file>`
- **Exemplar**: `mask customer PII before writing to application log.`
- **Weight**: High

### SEC-005: Insecure Direct Object Reference (IDOR)
- **Pattern**: Fetching resources by ID from request params without verifying ownership against authenticated tenant.
- **Verify**: Trace repository find method from controller to service layer.
- **Exemplar**: `verify resource belongs to current tenantId before return.`
- **Weight**: High

### SEC-006: Disabled TLS/SSL Verification
- **Pattern**: `trustAllCerts`, `InsecureSkipVerify`, or disabled hostname checks in HTTP client config.
- **Verify**: `grep -En "(InsecureSkipVerify|TrustAllStrategy|ALLOW_ALL_HOSTNAME_VERIFIER)" <file>`
- **Exemplar**: `remove insecure TLS trust manager.`
- **Weight**: High

### SEC-007: Missing CSRF or CORS Restrictions
- **Pattern**: Permissive CORS headers (`*`) on endpoints handling authenticated state.
- **Verify**: Inspect security configuration classes.
- **Exemplar**: `restrict CORS origins to trusted domains.`
- **Weight**: Medium

### SEC-008: Sensitive Data in URL Query Parameters
- **Pattern**: Passing tokens, auth codes, or personal data via query params instead of request headers or body.
- **Verify**: Inspect route definitions and outgoing HTTP client calls.
- **Exemplar**: `pass auth token via Authorization header, not URL parameter.`
- **Weight**: High

---

## 2. Error Handling & Reliability (ERR)

### ERR-001: Swallowed Exception
- **Pattern**: Empty catch block or catching Exception without re-throwing or logging.
- **Verify**: `grep -En "catch\s*\(.*\)\s*\{\s*\}" <file>`
- **Exemplar**: `log or rethrow caught exception.`
- **Weight**: High

### ERR-002: Catching Generic Throwable or Error
- **Pattern**: Catching `Throwable` or `Error` instead of specific `Exception` subclasses.
- **Verify**: `grep -En "catch\s*\((Throwable|Error)" <file>`
- **Exemplar**: `catch specific exception instead of Throwable.`
- **Weight**: Medium

### ERR-003: Missing Null Guard on Optional Return
- **Pattern**: Calling `.get()` on an Optional or dereferencing nullable database query result without check.
- **Verify**: Trace variable declaration to ensure `.isPresent()` or null guard is present.
- **Exemplar**: `check isPresent() before calling .get().`
- **Weight**: High

### ERR-004: Missing Timeout on Outgoing HTTP Call
- **Pattern**: HTTP client instances instantiated without explicit connect and read timeouts.
- **Verify**: Trace HTTP client builder configuration.
- **Exemplar**: `set explicit connect and read timeouts on HTTP client.`
- **Weight**: High

### ERR-005: Unbounded Retry Loop
- **Pattern**: Retry logic without max attempt ceiling or exponential backoff.
- **Verify**: Inspect loop or retry template configuration.
- **Exemplar**: `add max retry attempts and backoff to retry loop.`
- **Weight**: High

### ERR-006: Missing Default Fallback in Switch Statement
- **Pattern**: Switch expression over non-exhaustive enum or string without a default branch.
- **Verify**: Inspect switch block syntax.
- **Exemplar**: `add default branch to handle unexpected enum values.`
- **Weight**: Medium

---

## 3. Database & Concurrency (DB)

### DB-001: N+1 Query in Loop
- **Pattern**: Calling a database repository query method inside a `for` or `forEach` loop.
- **Verify**: Inspect loop bodies for repository or entityManager invocations.
- **Exemplar**: `fetch records in batch using IN clause to avoid N+1 queries.`
- **Weight**: High

### DB-002: Missing Database Index on Foreign Key
- **Pattern**: New database migration adding a foreign key column without creating a matching index.
- **Verify**: Inspect migration SQL or Flyway scripts.
- **Exemplar**: `create index on new foreign key column.`
- **Weight**: High

### DB-003: Long-Running HTTP Call Inside Transaction
- **Pattern**: Calling an external HTTP service inside a `@Transactional` block.
- **Verify**: Inspect methods annotated with `@Transactional` for external network calls.
- **Exemplar**: `move external API call outside @Transactional boundary.`
- **Weight**: High

### DB-004: Table Scan on Unindexed WHERE Clause
- **Pattern**: Adding a query with filter criteria on large table columns lacking indexes.
- **Verify**: Check table migration history for indexed columns.
- **Exemplar**: `add index on filter column to prevent full table scan.`
- **Weight**: Medium

### DB-005: Missing Optimistic Locking on Concurrent Entity
- **Pattern**: Modifying high-contention entities without a `@Version` field or row lock.
- **Verify**: Inspect entity class definition.
- **Exemplar**: `add @Version field to prevent race conditions during updates.`
- **Weight**: Medium

---

## 4. API Design & Contracts (API)

### API-001: Breaking Change to Public Response Schema
- **Pattern**: Removing or renaming an existing field in an external-facing response DTO.
- **Verify**: Compare previous commit diff of the DTO file.
- **Exemplar**: `preserve deprecated field for backwards compatibility.`
- **Weight**: High

### API-002: Inappropriate HTTP Status Code
- **Pattern**: Returning 200 OK on resource creation or 500 Internal Error on validation failure.
- **Verify**: Trace controller response building logic.
- **Exemplar**: `return 201 Created on successful entity creation.`
- **Weight**: Medium

### API-003: Unversioned REST Endpoint
- **Pattern**: Adding an endpoint path without an explicit API version segment (e.g. `/v1/`).
- **Verify**: Inspect `@RequestMapping` or route string.
- **Exemplar**: `prefix endpoint path with /v1/.`
- **Weight**: Medium

### API-004: Unbounded Collection Response
- **Pattern**: Returning a list endpoint without pagination parameters (`page`, `size`, `limit`).
- **Verify**: Check controller method arguments and query layer.
- **Exemplar**: `add pagination to list endpoint.`
- **Weight**: High

---

## 5. Code Structure & Cleanliness (STR)

### STR-001: Bloated Function (>50 Lines)
- **Pattern**: Single function or method exceeding 50 lines doing multiple orthogonal tasks.
- **Verify**: Count line numbers between function start and end.
- **Exemplar**: `extract validation and persistence into separate methods.`
- **Weight**: Low

### STR-002: Deep Nesting (>3 Levels)
- **Pattern**: If/for/try blocks nested deeper than 3 indentation levels.
- **Verify**: Inspect indentation depth.
- **Exemplar**: `use guard clauses to flatten nested conditionals.`
- **Weight**: Medium

### STR-003: Duplicated Code Block (>15 Lines)
- **Pattern**: Identical logic pasted across multiple methods in the diff.
- **Verify**: Diff comparison across changed files.
- **Exemplar**: `extract shared logic into private helper function.`
- **Weight**: Low

---

## 6. Observability & Logging (OBS)

### OBS-001: Missing Correlation ID in Logs
- **Pattern**: Asynchronous worker thread or scheduled task spinning up without inheriting MDC/traceId.
- **Verify**: Check task executor or thread pool definition.
- **Exemplar**: `propagate MDC context to background thread.`
- **Weight**: High

### OBS-002: Logging Inside Tight Loop
- **Pattern**: Calling `log.info` inside a high-throughput loop over thousands of records.
- **Verify**: Inspect loops over large datasets for logging calls.
- **Exemplar**: `log summary after loop completes instead of per iteration.`
- **Weight**: Medium

### OBS-003: Missing Metrics on Business Critical Flow
- **Pattern**: New payment or billing handler without timer or counter metrics.
- **Verify**: Check service methods for meter registry calls.
- **Exemplar**: `record metric timer on payment processing path.`
- **Weight**: Medium

---

## 7. Testing & Coverage (TST)

### TST-001: Missing Unit Test for New Branch
- **Pattern**: Adding conditional logic without a corresponding test case covering both branches.
- **Verify**: Compare diff lines in source vs diff lines in test directory.
- **Exemplar**: `add test case covering false branch of guard clause.`
- **Weight**: High

### TST-002: Test Assertion Without Verification
- **Pattern**: Test executing service call without assertions, or asserting only `assertNotNull`.
- **Verify**: Inspect `@Test` method bodies.
- **Exemplar**: `add assertion validating updated entity status.`
- **Weight**: High

### TST-003: Sleep Used for Asynchronous Test Synchronization
- **Pattern**: `Thread.sleep()` used to wait for background jobs in test code.
- **Verify**: `grep -En "Thread\.sleep\(" <test_file>`
- **Exemplar**: `use Awaitility instead of Thread.sleep.`
- **Weight**: Medium

---

## 8. Cucumber & BDD Scenarios (BDD)

### BDD-001: Implementation Details in Scenario Step
- **Pattern**: Scenario mentioning UI clicks, CSS selectors, or database tables directly.
- **Verify**: Inspect `.feature` files for technical jargon.
- **Exemplar**: `rephrase step in terms of user behavior, not UI elements.`
- **Weight**: Medium

### BDD-002: Duplicate Step Definition
- **Pattern**: Defining a new step regex that matches an existing step definition in glue code.
- **Verify**: Grep across test step definition classes.
- **Exemplar**: `reuse existing step definition in CommonSteps.java.`
- **Weight**: Medium

---

## 9. Process & Pipeline (PRC)

### PRC-001: Giant PR (>500 Lines Diff)
- **Pattern**: Pull request containing hundreds of modified lines across unrelated concerns.
- **Verify**: Check line counts in `diffs.json`.
- **Exemplar**: `split changes into smaller, focused pull requests.`
- **Weight**: Low

### PRC-002: Broken CI Pipeline Due to Diff
- **Pattern**: CI build or test failure directly attributable to changed lines.
- **Verify**: Inspect `pipeline.json` failure logs.
- **Exemplar**: `fix broken compilation in client module.`
- **Weight**: High

---

## 10. Design & Spec Alignment (DES)

### DES-001: Mismatch with Architecture Spec
- **Pattern**: Implementation violates design constraints specified in linked Jira ticket or ADR.
- **Verify**: Cross-reference Jira acceptance criteria with code behavior.
- **Exemplar**: `align payout timing with 24h delay specified in ticket spec.`
- **Weight**: High

---

## 11. Cross-Repo Impact (XRP)

### XRP-001: Breaking Change on Shared Interface
- **Pattern**: Modifying contract or message topic consumed by sibling services.
- **Verify**: Grep default branches of sibling clones for the altered contract.
- **Exemplar**: `coordinate schema migration with consumer service before deploy.`
- **Weight**: High

---

## 12. Domain Integrity (DOM)

### DOM-001: Invalid Financial Rounding
- **Pattern**: Using floating point math (`float`, `double`) for monetary currency calculations.
- **Verify**: `grep -En "(float|double)\s+\w*(amount|price|balance|fee)" <file>`
- **Exemplar**: `use BigDecimal with explicit RoundingMode for monetary amounts.`
- **Weight**: High

---

## 13. Naming Conventions (NAM)

### NAM-001: Misleading Variable Name
- **Pattern**: Boolean variable named without affirmative prefix (`is`, `has`, `should`).
- **Verify**: Inspect variable declarations.
- **Exemplar**: `prefix boolean variable with is or has.`
- **Weight**: Low

---

## 14. Configuration & Environment (CFG)

### CFG-001: Hardcoded URL or Hostname
- **Pattern**: Hardcoded domain name or IP address in service code.
- **Verify**: `grep -En "https?://[a-zA-Z0-9.-]+" <file>`
- **Exemplar**: `move endpoint URL to application configuration file.`
- **Weight**: High
