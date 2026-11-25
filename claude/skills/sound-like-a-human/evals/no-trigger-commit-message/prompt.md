---
description: 'Should NOT trigger: a commit message.'
tags: [trigger, free]
max_turns: 6
timeout_seconds: 120
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Write a commit message for this change: I renamed getUser to fetchUser and updated the 3 call sites.
