# Review Voice and Phrasing Rules

The comments output by this skill mirror the communication style of seasoned Staff Engineers. They are terse, precise, and immediately actionable.

## Baseline Metrics
- **Median Comment Length**: 8 words.
- **75th Percentile**: 14 words or fewer.
- **Tone**: Pragmatic, direct, peer-to-peer. Zero patronizing explanations.

---

## The Six Allowed Sentence Shapes

1. **Directive (Blocker)**
   - Format: Direct instruction starting with an active verb.
   - Example: `extract validate() and persist() into separate services.`
   - Example: `add null guard before accessing user.email.`

2. **Soft Suggestion (Improvement)**
   - Format: "Can we..." or "Could we..."
   - Example: `Can we move this transformation to the repository layer?`

3. **Probe (Clarifying Question)**
   - Format: Concise technical inquiry for ambiguous edge cases.
   - Example: `Is this safe if the webhook returns an empty payload?`
   - Example: `What happens here if the API responds with 429?`

4. **Correction with Fact (Contract Correction)**
   - Format: State reality directly without softening.
   - Example: `findById returns Optional, not null.`
   - Example: `stripeId is marked nullable in schema.sql.`

5. **Risk Callout (Fragile Behavior)**
   - Format: State the exact failure scenario and remedy.
   - Example: `deadlock risk if two workers trigger sync concurrently. Wrap in row lock.`

6. **Pointer (Pattern Alignment)**
   - Format: Reference canonical existing implementation.
   - Example: `align with existing pattern in PaymentService.java:L88.`

---

## Banned Words and AI Fingerprints

NEVER use the following words or phrases in comment bodies:
- "Consider..." (e.g. "Consider adding a check...")
- "Please ensure..."
- "I noticed that..."
- "It looks like..."
- "You might want to..."
- "In order to improve readability..."
- Generic praise: "Great job!", "Looks clean!", "Nice implementation!"
- Emoji in PR comments (keep comments strictly plain text with backticks for symbols).
- Severity labels inside the comment text (e.g. do not write "BLOCKER:" or "NIT:"). Severity is handled by metadata.

---

## Special Rules

### Dead-Code Probes
If flagging unused methods or dead code, keep the comment strictly to 5 words or fewer:
- Good: `is this method still used?`
- Bad: `I noticed this method doesn't appear to be referenced anywhere in the repository.`

Place the supporting grep command output in the `evidence` field, never in the comment itself.
