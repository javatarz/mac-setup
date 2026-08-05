---
id: 02_sheet_range_read
purpose: Reading a specific range from a Google Sheet should use the sheets +read fast path, with the spreadsheet ID pulled from the URL.
expected_behavior:
  - Extracts the spreadsheetId from the URL (between /spreadsheets/d/ and /edit)
  - Plans to run gws sheets +read --spreadsheet <ID> --range 'Budget!A1:C20' (or the equivalent raw spreadsheets.values.get call)
  - Does not propose opening the sheet in a browser or fetching the URL directly
expected_verdict: pass
notes: >
  Should not require re-deriving the whole spreadsheet — a range read is
  the correct minimal call, not a full spreadsheets.get of everything.
---

What are the numbers in the "Budget" tab, rows 1 through 20, columns A to C,
of this spreadsheet?

https://docs.google.com/spreadsheets/d/1XyZ9876543210QwErTyUiOpAsDfGh/edit#gid=0
