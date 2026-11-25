"""Print the result of evals/smoke.sh and exit non-zero if any case failed.

Usage: smoke-report.py <result.json> <plugin dir> <model> <smoke.sh path> <report.html>
"""
import json
import sys

result_path, plugin, model, smoke, report = sys.argv[1:6]
with open(result_path) as f:
    data = json.load(f)

failures = []
errors = []
for case in data.get("cases", []):
    for run in case.get("arms", {}).get("with", []):
        if run.get("error"):
            errors.append((case["name"], run["error"]))
            continue
        for g in run.get("graders", []):
            if not g.get("passed"):
                failures.append((case["name"], g["name"], g.get("explanation", ""), g.get("evidence")))

total = len(data.get("cases", []))
print(f"Smoke eval: {total} cases, ${data.get('costUsd', 0):.2f}, {data.get('durationSeconds', 0):.0f}s")

if not failures and not errors:
    print("Smoke eval passed.")
    sys.exit(0)

for name, err in errors:
    print(f"ERROR in case {name}: the run ended abnormally ({err}).", file=sys.stderr)
    print("  Why: an API error, rate limit or timeout, not a skill problem.", file=sys.stderr)
    print(f"  Fix: commit again, or re-run: claude plugin eval {plugin} --case {name} --runs 1 --ablation none --model {model}", file=sys.stderr)

for name, grader, why, evidence in failures:
    print(f"FAIL case {name}, grader {grader}: {why}", file=sys.stderr)
    if evidence:
        print("  Output the judge saw: " + str(evidence)[:300].replace("\n", " "), file=sys.stderr)
    print(f"  Grader: {plugin}/evals/{name}/graders/{grader}.md", file=sys.stderr)
    print(f"  Re-run: claude plugin eval {plugin} --case {name} --runs 1 --ablation none --model {model}", file=sys.stderr)

print(f"Report with each run's output and verdicts: {report}", file=sys.stderr)
print("One failing run can be noise. Re-run the case: if it fails again, a skill change broke it (fix the skill) or the grader is wrong (fix the grader).", file=sys.stderr)
print(f"To commit anyway: SKIP_SKILL_EVALS=1 git commit ...  (model and cost cap live at the top of {smoke})", file=sys.stderr)
print("COMMIT BLOCKED by the smoke eval.", file=sys.stderr)
sys.exit(1)
