---
id: 05_sheet_append
purpose: A write operation (append a row) should use the sheets +append fast path rather than a full values.update overwrite.
expected_behavior:
  - Extracts the spreadsheetId from the URL
  - Plans to run gws sheets +append --spreadsheet <ID> --values '...' (or --json-values for the multi-column row)
  - Does not propose reading the whole sheet first and rewriting it, and does not propose a destructive update/clear call
expected_verdict: pass
notes: >
  Checks that append semantics are preserved — a regression might route
  this through a generic values.update call that could clobber existing
  rows if the range is miscalculated.
---

Add a new row to this expense tracker with: "2026-08-05", "Client dinner",
"142.50", "Pending"

https://docs.google.com/spreadsheets/d/1MnBvCxZaSdFgHjKlPoIuYtReWq/edit
