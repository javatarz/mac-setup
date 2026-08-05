---
id: 01_doc_read_via_url
purpose: Basic routing check — reading a Google Doc from a shared URL must go through gws, not WebFetch.
expected_behavior:
  - Extracts the document ID directly from the URL path (between /document/d/ and /edit)
  - Plans to run gws docs documents get (or gws drive files export with mimeType text/plain) with that documentId
  - Does not fetch the URL as a webpage first
expected_verdict: pass
notes: >
  The URL itself is the trap: an agent without this skill will often just
  WebFetch it. Fail if WebFetch (or any HTTP fetch of the docs.google.com
  URL) appears anywhere in the plan.
---

Can you read through this Google Doc and summarize the key points?

https://docs.google.com/document/d/1AbCdEfGhIjKlMnOpQrStUvWxYz1234567890abc/edit
