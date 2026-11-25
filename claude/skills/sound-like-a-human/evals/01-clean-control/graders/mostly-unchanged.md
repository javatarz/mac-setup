---
type: llm
---

The original text is clean and already in the author's voice. PASS if the reply is the same text with at most 2 small edits: nearly every sentence is kept word for word, and nothing was added or removed that changes the story. FAIL if sentences were rewritten, merged, or reordered, or if facts were added or dropped. An identical copy of the original is a PASS. The judge sees only the reply, not the request, so the original text is below.

Original text:

<original>
Our deploy pipeline silently swallowed failed migrations for two months. I found the bug by accident.

A teammate told me a schema change "didn't seem to take," and when I checked, the migration step had exited 0 even though Postgres had rejected the DDL. The wrapper script piped stderr to `/dev/null` and checked the exit code of the pipe, not the migration command (a classic `set -o pipefail` gap).

The fix was small: 3 lines. Explaining to the team why we'd shipped 6 migrations that never ran was harder. I don't think it's anyone's fault. The script predates most of us, and no one had a reason to read it closely until something broke.

From now on, any pipeline step that touches schema gets a post-check that queries `information_schema` directly instead of trusting the tool's exit code. It's not glamorous, but it would have caught this in minutes instead of two months.
</original>
