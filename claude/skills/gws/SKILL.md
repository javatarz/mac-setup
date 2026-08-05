---
name: gws
description: >
  Route all Google Docs, Sheets, Slides, and Drive file access through the
  `gws` CLI instead of any other tool. Use whenever a task involves reading,
  writing, searching, exporting, or creating a Google Workspace file — a
  docs.google.com/drive.google.com URL, a "check my Google Doc/Sheet/Slides"
  request, or anything referencing a spreadsheet, presentation, or Drive
  folder.
---

## Rule

Any time a task touches a Google Doc, Sheet, Slide deck, or Drive file (or
its metadata — permissions, revisions, comments, sharing) use `gws`. Do not:

- `WebFetch` a `docs.google.com` / `drive.google.com` URL
- Use the `mcp__claude_ai_Google_Drive__*` tools
- Guess at a Google API request by hand, or tell the user you can't access it

`gws` is the single authenticated path to Workspace data on this machine —
it already carries the right OAuth scopes and credentials, and every call
goes through one auditable place. If `gws` genuinely can't do something,
say so explicitly rather than quietly falling back to another tool.

(Gmail and Calendar access aren't covered by this rule — the existing MCP
tools for those are fine. `gws` also has `gmail`/`calendar` services if a
task needs both a Workspace file and a calendar/mail action in the same
breath, but nothing here mandates switching those over.)

## Discovery first — the CLI surface will change

Don't treat the commands below as gospel. `gws` gains services, resources,
and flags over time, and this file will drift out of date. Before running an
unfamiliar command:

1. `gws` (no args) — lists all services.
2. `gws <service> --help` — lists resources for a service, e.g. `gws drive --help`.
3. `gws <service> <resource> --help` — lists methods, e.g. `gws drive files --help`.
4. `gws <service> <resource> <method> --help` — flags for one method.
5. `gws schema <service.resource.method> [--resolve-refs]` — full request/param
   schema when `--help` isn't enough, e.g. `gws schema drive.files.list`.
6. `--dry-run` on any command validates the request locally without sending
   it — use it to sanity-check `--params`/`--json` shape before a write.

If a task needs a flag or parameter you're not confident about, run
`--help` or `gws schema ...` first rather than guessing the JSON shape.
Never fabricate a field name for `--params`/`--json` — check the schema.

## Shape of every call

```
gws <service> <resource> [sub-resource] <method> [--params JSON] [--json JSON] [flags]
gws <service> +<helper> [flags]      # shortcuts for common operations
```

Services relevant to file access: `drive`, `docs`, `sheets`, `slides`.

## Fast paths

These worked as of the CLI version on this machine — verify with `--help`
if a call errors, since flags may have moved on.

**Find a file (most workflows start by resolving a name/URL to an ID):**
```
gws drive files list --params '{"q": "name contains '\''Q3 Plan'\''", "fields": "files(id,name,mimeType)"}'
```

**Read a Doc:**
```
gws docs documents get --params '{"documentId": "DOC_ID"}'
# or export as plain text:
gws drive files export --params '{"fileId": "DOC_ID", "mimeType": "text/plain"}'
```

**Append text to a Doc:**
```
gws docs +write --document DOC_ID --text 'Hello, world!'
```

**Read a Sheet range:**
```
gws sheets +read --spreadsheet SHEET_ID --range 'Sheet1!A1:D10'
```

**Append a row to a Sheet:**
```
gws sheets +append --spreadsheet SHEET_ID --json-values '[["a","b"]]'
```

**Read a Slides deck:**
```
gws slides presentations get --params '{"presentationId": "DECK_ID"}'
```

**Upload a local file to Drive:**
```
gws drive +upload ./report.pdf --parent FOLDER_ID
```

## Getting an ID from a URL

Google Workspace URLs embed the resource ID directly — pull it out instead
of fetching the page:

- `docs.google.com/document/d/<ID>/edit` → `documentId`
- `docs.google.com/spreadsheets/d/<ID>/edit` → `spreadsheetId`
- `docs.google.com/presentation/d/<ID>/edit` → `presentationId`
- `drive.google.com/file/d/<ID>/view` → `fileId`

## Auth

Credentials come from `GOOGLE_WORKSPACE_CLI_TOKEN`,
`GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE`, or
`GOOGLE_WORKSPACE_CLI_CLIENT_ID`/`_CLIENT_SECRET`. `gws auth status` shows
current auth state; `gws auth login` re-authenticates. Exit code `2` from
any `gws` call means an auth error specifically (see `gws --help` for the
full exit-code table) — surface that to the user rather than switching to
another tool to route around it.
