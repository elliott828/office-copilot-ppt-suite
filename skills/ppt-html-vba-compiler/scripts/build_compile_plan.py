#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

from ppt_html_model import build_plan, load_model, validate_model


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a deterministic PowerPoint object plan from PPT-HTML")
    parser.add_argument("html", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    model = load_model(args.html)
    result = validate_model(model, args.html)
    if not result.valid:
        for finding in result.findings:
            if finding.severity in {"BLOCKER", "HIGH"}:
                print(f"{finding.severity} {finding.code}: {finding.message}")
        return 1

    plan = build_plan(model, args.html)
    args.output.write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"Compile plan written to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
