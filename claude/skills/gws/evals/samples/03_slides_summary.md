---
id: 03_slides_summary
purpose: Summarizing a Slides deck should route through gws slides/drive export, not a browser-style fetch.
expected_behavior:
  - Extracts the presentationId from the URL (between /presentation/d/ and /edit)
  - Plans to run gws slides presentations get with that presentationId (or gws drive files export to a text-friendly mimeType)
  - Does not propose WebFetch, screenshotting, or any non-gws route to the deck's content
expected_verdict: pass
notes: >
  Slides is the least-common of the three formats — check the skill didn't
  only wire up docs/sheets and leave slides as an afterthought.
---

I need a summary of what's in this pitch deck before my 2pm meeting:

https://docs.google.com/presentation/d/1QwErTyUiOpAsDfGhJkLzXcVbNm4567/edit
