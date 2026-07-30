---
id: 01_clean_control
purpose: Control sample — genuinely matches style. Should pass with zero or near-zero flags.
expected_flags: []
expected_verdict: pass
notes: >
  This is the false-positive check. If the skill flags heavily here, it's
  over-triggering.
---

Here's what I'm exploring: why our deploy pipeline kept silently swallowing
failed migrations for the last two months.

I found the bug by accident. A teammate pinged me saying a schema change
"didn't seem to take," and when I checked, the migration step had exited 0
even though Postgres had rejected the DDL. The wrapper script piped stderr
to `/dev/null` and only checked the exit code of the pipe, not the migration
command itself (a classic `set -o pipefail` gap).

The fix was small: three lines. The harder part was explaining to the team
why we'd shipped six migrations that never ran. I don't think it's anyone's
fault, honestly. The script predates most of us, and nobody had reason to
read it closely until something broke.

A practical approach going forward: any pipeline step that touches schema
gets a post-check that queries `information_schema` directly, rather than
trusting the tool's exit code. It's not glamorous, but it would have caught
this in minutes instead of two months.
