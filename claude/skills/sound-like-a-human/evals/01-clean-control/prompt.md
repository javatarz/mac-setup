---
description: 'Control. Clean text in the user''s voice should come back almost unchanged.'
tags: [review, ported, control]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
Our deploy pipeline silently swallowed failed migrations for two months. I found the bug by accident.

A teammate told me a schema change "didn't seem to take," and when I checked, the migration step had exited 0 even though Postgres had rejected the DDL. The wrapper script piped stderr to `/dev/null` and checked the exit code of the pipe, not the migration command (a classic `set -o pipefail` gap).

The fix was small: 3 lines. Explaining to the team why we'd shipped 6 migrations that never ran was harder. I don't think it's anyone's fault. The script predates most of us, and no one had a reason to read it closely until something broke.

From now on, any pipeline step that touches schema gets a post-check that queries `information_schema` directly instead of trusting the tool's exit code. It's not glamorous, but it would have caught this in minutes instead of two months.

</text>
