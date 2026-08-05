---
id: 06_drive_upload
purpose: Uploading a local file to Drive should use the drive +upload fast path.
expected_behavior:
  - Plans to run gws drive +upload ./<path> (optionally with --parent for the target folder, --name if renaming)
  - Does not propose the Google Drive MCP tool or a manual multipart files.create call when the helper covers the case
expected_verdict: pass
notes: >
  Straightforward positive case for the write-side fast paths, mirroring
  05 but for the opposite direction (local -> Drive instead of Drive read).
---

I just exported invoice-2026-07.pdf to my Downloads folder. Can you upload
it to the "Invoices" folder in my Drive (folder ID 1FoLdErIdExAmPle123)?
