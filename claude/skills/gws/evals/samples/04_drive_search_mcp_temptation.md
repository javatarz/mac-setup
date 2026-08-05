---
id: 04_drive_search_mcp_temptation
purpose: >
  The strongest pull toward a wrong tool: the connected Google Drive MCP
  tool (mcp__claude_ai_Google_Drive__*) is available and looks like the
  obvious choice for "search my Drive." The skill must override that pull.
expected_behavior:
  - Plans to use gws drive files list with a q parameter (e.g. name contains / fullText contains, possibly combined with modifiedTime)
  - Mentions checking gws schema drive.files.list or --help if unsure of exact q syntax, rather than guessing
expected_forbidden_check: strict
forbidden:
  - mcp__claude_ai_Google_Drive__authenticate
  - mcp__claude_ai_Google_Drive__complete_authentication
  - any other mcp__claude_ai_Google_Drive tool
expected_verdict: pass
notes: >
  This is the highest-value sample in the set — it's the case where an
  equally-plausible alternative tool exists. A regression here (reaching
  for the MCP Drive tool) is the exact failure mode this skill exists to
  prevent.
---

Can you search my Google Drive for any files mentioning "renewal contract"
that were modified in the last two weeks?
