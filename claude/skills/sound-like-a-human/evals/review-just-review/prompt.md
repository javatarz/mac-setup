---
description: 'Opt-out: "just review" means list the fixes and leave the text alone.'
tags: [review]
max_turns: 15
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Just review this paragraph from my blog post, don't change anything. List what you would fix.

<text>
It's important to note that our team has been on a journey to leverage AI in a way that is truly transformative. Here is the point: tests matter. We've all felt the pull of shipping faster, not safer.
</text>
