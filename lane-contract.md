# Lane Contract & Rubric

Every sub-agent review lane must strictly adhere to this input/output contract.

## Input Parameters
Each lane receives:
- `WORKDIR`: Path to directory containing pre-processed artifacts (`annotated.txt`, `context.json`, `diffs.json`, etc.).
- `MR_URL`: Full link to the active pull/merge request.
- Reference access to `data/learnings.json`.

---

## Output JSON Schema
Every lane agent MUST return a single JSON object conforming to this shape:

```json
{
  "LANE": "code",
  "STATUS": "ok",
  "FINDINGS": [
    {
      "anchor": "path/to/file.ext:L42",
      "rule": "ERR-003",
      "severity": "blocker",
      "draft": "user can be null after find(). Add null guard before .email.",
      "evidence": "grep output or file read verifying the lack of guard at lines 40-44",
      "confidence": 92
    }
  ],
  "NOTES": "Optional brief context on lane coverage or skipped areas"
}
```

### Fields
- `LANE`: One of `code`, `design`, `tests`, `precedents`, `security`.
- `STATUS`: `ok`, `partial` (e.g. external tools unavailable), or `skipped`.
- `FINDINGS`: List of findings.
  - `anchor`: Exact `<file_path>:L<line_number>` or `<file_path>:L<start>-L<end>`. Must match `annotated.txt`.
  - `rule`: Rule ID from `review-rules.md` (e.g., `SEC-002`, `DB-005`).
  - `severity`: One of `blocker`, `risk`, `probe`, `nit`.
  - `draft`: Proposed comment body matching `voice.md` rules.
  - `evidence`: Direct command output or line reproduction proving the issue.
  - `confidence`: Integer between 0 and 100.
- `NOTES`: Short diagnostic note if needed.

---

## Confidence Score Rubric

| Range | Classification | Action | Description |
|---|---|---|---|
| **90 - 100** | High Blocker | Post as Directive | Reproduced with deterministic grep/read. Definite runtime bug, security issue, or contract break. |
| **80 - 89** | Valid Finding | Post as Finding | Strong evidence present, minor contextual uncertainty. |
| **60 - 79** | Tentative Probe | Post as Question | Plausible edge case or question. Phrased as a question, never a directive. |
| **< 60** | Low Confidence | Drop Silently | Inconclusive or unverified. Never exposed in review output. |

### Verifier Constraints
- The `verifier` agent evaluates all lane outputs.
- A finding marked `KEEP` by the verifier MUST have confidence >= 80.
- Any finding between 60-79 is automatically converted to `DOWNGRADE_TO_PROBE`.
- Any finding below 60 is converted to `DROP`.
