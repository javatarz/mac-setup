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
cases[].aggregates.score, costUsd, durationSeconds, partial, partialReason.
Unknown or missing fields are skipped, not treated as errors.
"""

import json
import os
import sys


def load(path):
    with open(path) as f:
        data = json.load(f)
    label = os.path.splitext(os.path.basename(path))[0]
    scores = {}
    for c in data.get("cases") or []:
        score = (c.get("aggregates") or {}).get("score")
        scores[c.get("name", "?")] = score
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

    runs = [load(p) for p in paths]
    labels = [r["label"] for r in runs]

    summary = [["", *labels]]
    summary.append(["overall score", *(fmt(r["overall"], ".2f") for r in runs)])
    summary.append(["cases passed", *(
        "-" if r["passed"] is None else f"{r['passed']}/{r['total']}" for r in runs)])
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
        known = [v for v in vals if v is not None]
        spread = max(known) - min(known) if len(known) > 1 else None
        per_case.append([n, *(fmt(v, ".2f") for v in vals), fmt(spread, ".2f")])
    print("\nPer case (spread = best minus worst model; a big spread marks a model-sensitive case):")
    print(table(per_case))
    return 0


if __name__ == "__main__":
    sys.exit(main())
