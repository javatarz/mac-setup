#!/usr/bin/env python3
"""Compare `claude plugin eval --json` results from several models. Stdlib only.

Usage:
  compare-results.py results/models-.../*.json
  compare-results.py opus.json sonnet.json haiku.json

Each file is one run of the suite. The column label is the file name without
".json" (run-models.sh names files after the model). Prints the overall score,
cost, and one row per case. Scores are the with-skill arm, 0 to 1.

Reads these fields of the result document (schemaVersion 1): aggregates.overallScore,
aggregates.casesPassed, aggregates.casesTotal, cases[].name,
cases[].aggregates.score, cases[].arms.with[].error, aggregates.meanDelta, costUsd, durationSeconds, partial, partialReason.
Unknown or missing fields are skipped, not treated as errors.
"""

import json
import os
import sys


def load(path):
    try:
        with open(path) as f:
            data = json.load(f)
        if not isinstance(data, dict):
            raise ValueError("top level is not a JSON object")
    except (OSError, ValueError) as err:
        print(f"warning: skipping {path}: {err}", file=sys.stderr)
        return None
    label = os.path.splitext(os.path.basename(path))[0]
    scores = {}
    errored_cases = set()
    errored_runs = 0
    for c in data.get("cases") or []:
        name = c.get("name", "?")
        scores[name] = (c.get("aggregates") or {}).get("score")
        # A run that ended abnormally (API error, or a timeout) may score 0
        # without grading. Count it so a rate limit does not read as a bad model.
        n = sum(1 for a in ((c.get("arms") or {}).get("with") or []) if a.get("error"))
        if n:
            errored_runs += n
            errored_cases.add(name)
    agg = data.get("aggregates") or {}
    return {
        "label": label,
        "overall": agg.get("overallScore"),
        "passed": agg.get("casesPassed"),
        "total": agg.get("casesTotal"),
        "cost": data.get("costUsd"),
        "seconds": data.get("durationSeconds"),
        "partial": data.get("partialReason") if data.get("partial") else None,
        "scores": scores,
        "errored_cases": errored_cases,
        "errored_runs": errored_runs,
        "delta": agg.get("meanDelta"),
    }


def fmt(value, spec):
    return "-" if value is None else format(value, spec)


def table(rows):
    widths = [max(len(str(r[i])) for r in rows) for i in range(len(rows[0]))]
    lines = []
    for n, row in enumerate(rows):
        cells = [str(row[0]).ljust(widths[0])] + [str(c).rjust(w) for c, w in zip(row[1:], widths[1:])]
        lines.append("  ".join(cells))
        if n == 0:
            lines.append("  ".join("-" * w for w in widths))
    return "\n".join(lines)


def main():
    paths = []
    for arg in sys.argv[1:]:
        if os.path.isdir(arg):
            paths += sorted(os.path.join(arg, n) for n in os.listdir(arg) if n.endswith(".json"))
        else:
            paths.append(arg)
    if not paths:
        print(__doc__)
        return 2

    runs = [r for r in (load(p) for p in paths) if r]
    if not runs:
        print("No readable result files.", file=sys.stderr)
        return 1
    labels = [r["label"] for r in runs]

    summary = [["", *labels]]
    summary.append(["overall score", *(fmt(r["overall"], ".2f") for r in runs)])
    summary.append(["cases passed", *(
        "-" if r["passed"] is None else f"{r['passed']}/{r['total']}" for r in runs)])
    summary.append(["errored runs", *(str(r["errored_runs"]) for r in runs)])
    if any(r["delta"] is not None for r in runs):
        summary.append(["mean delta vs no skill", *(fmt(r["delta"], ".2f") for r in runs)])
    summary.append(["cost (USD)", *(fmt(r["cost"], ".2f") for r in runs)])
    summary.append(["seconds", *(fmt(r["seconds"], ".0f") for r in runs)])
    print(table(summary))

    partial = [f"{r['label']}: {r['partial']}" for r in runs if r["partial"]]
    if partial:
        print("\nPartial runs (leave out of comparisons): " + "; ".join(partial))

    names = []
    for r in runs:
        for n in r["scores"]:
            if n not in names:
                names.append(n)

    per_case = [["case", *labels, "spread"]]
    for n in names:
        vals = [r["scores"].get(n) for r in runs]
        # Cases with an errored run are marked and left out of the spread.
        clean = [v for v, r in zip(vals, runs) if v is not None and n not in r["errored_cases"]]
        spread = max(clean) - min(clean) if len(clean) > 1 else None
        cells = [fmt(v, ".2f") + ("*" if n in r["errored_cases"] else "") for v, r in zip(vals, runs)]
        per_case.append([n, *cells, fmt(spread, ".2f")])
    print("\nPer case (spread = best minus worst model; a big spread marks a model-sensitive case).")
    print("* = at least one run ended abnormally (API error or timeout), so the score is not trustworthy and is left out of the spread.")
    print(table(per_case))
    return 0


if __name__ == "__main__":
    sys.exit(main())
