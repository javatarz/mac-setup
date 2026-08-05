---
id: 08_unrelated_negative_control
purpose: >
  False-positive baseline — a task with no Google Workspace involvement at
  all. gws should not appear in the plan just because the skill is loaded.
expected_behavior:
  - Plan addresses the local CSV file directly (e.g. Read/pandas/shell tools)
  - Makes no mention of gws, Google Drive, or any Google Workspace service
expected_verdict: pass
forbidden:
  - gws
  - Google Drive
  - Google Sheets
notes: >
  This is the over-triggering check. If the skill fires here, it's too
  eager — e.g. it might wrongly suggest uploading the CSV to Sheets to
  "analyze" it when the user never asked for that.
---

Can you read through sales_data.csv in the current directory and tell me
the total revenue for Q2?
