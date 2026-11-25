---
description: 'Should NOT trigger: a pull request description.'
tags: [trigger, free]
max_turns: 6
timeout_seconds: 120
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Write a pull request description for this change: I renamed getUser to fetchUser and updated the 3 call sites.
