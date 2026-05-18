---
name: sadhak
description: >
  Query Sadhak (Sahaj's people/project data system) using mitra CLI tools.
  Use when asked about team members, project staffing, experience levels,
  assignments, recruitment, or any people/org data question.
---

You have access to `mitra` — a CLI toolkit that connects to Sadhak, Sahaj's people and project data system.

## Discovery

Run `mitra` (no args) to see all available tools with descriptions. Each tool also has its own bin wrapper — run `<tool> --help` to see its flags before using it.

## Invocation Pattern

Tools are invoked directly by name (not through `mitra`):

```bash
list_projects                          # no args needed
find_members --project-names "Solifi"  # outputs IDs when piped
find_members ... | member_details -f name role overallExperience  # pipe IDs in
```

Key pattern: **ID-producing commands pipe into detail commands.**

`find_members` outputs member IDs when stdout is a pipe — use this as the entry point for most people queries.

## Common Compositions

**People on a project:**
```bash
find_members --project-names "Project Name" | member_details --resolve-names -f name role currentStatus overallExperience
```

**Seniors on a project** (overall experience ≥ 8 years is a reasonable senior threshold — adjust if user specifies):
```bash
find_members --project-names "Project Name" --minimum-overall-experience 8 | member_details --resolve-names -f name role overallExperience
```

**Available/bench people:**
```bash
find_members --current-statuses BEACH | member_details --resolve-names -f name role overallExperience officeLocation
```

**How long someone has been on their project:**
```bash
find_members --search-query "Name" | assignment
```

**Joining date and tenure:**
```bash
find_members --project-names "Project Name" | historical_member_tenure
```

## Workflow

1. If the question involves a project name, first run `list_projects` to find the exact name (fuzzy match from user's phrasing).
2. Run `<tool> --help` if you're unsure of a flag — don't guess.
3. Always use `--resolve-names` on `member_details` or `find_members` calls when you need readable names in output.
4. If the user's question requires data a tool doesn't expose, tell them: "This data isn't available via mitra yet — you'd need to add a tool for it."

## Notes

- `find_members` filters are combinable (office + role + experience + project, etc.)
- `currentStatus` values: `BEACH` (available), `BILLABLE`, `NON_BILLABLE`, `INTERNAL`
- `role-types`: `PS` (professional services / client-facing), `NON_PS`
- Office locations: `Bangalore`, `Chennai`, `Pune`, `Hyderabad`, `Melbourne`, `San Francisco`, `London`
- When in doubt about available flags, run `--help` — it's always accurate.
