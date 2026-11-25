---
description: 'Should NOT trigger: a code change.'
tags: [trigger, free]
max_turns: 6
timeout_seconds: 120
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Rename the variable `cnt` to `retryCount` in this function and show me the result.

```python
def retry(fn):
    cnt = 0
    while cnt < 3:
        try:
            return fn()
        except Exception:
            cnt += 1
    raise RuntimeError('gave up')
```
