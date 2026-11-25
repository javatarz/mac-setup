---
description: 'Should trigger: asked for slide text.'
tags: [trigger, free]
max_turns: 12
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Write the text for one slide for my team talk. The slide explains why we moved our nightly jobs from cron to a workflow scheduler. Notes: cron had no retries, no alerting, and no dependency tracking. No questions back, just the slide text.
