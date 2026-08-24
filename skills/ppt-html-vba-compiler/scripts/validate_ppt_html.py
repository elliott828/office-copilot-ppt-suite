#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

from ppt_html_model import load_model, validate_model


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a constrained PPT-HTML package")
    parser.add_argument("html", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    try:
        model = load_model(args.html)
        result = validate_model(model, args.html)
    except Exception as exc:
        payload = {"valid": False, "findings": [{"severity": "BLOCKER", "code": "LOAD", "message": str(exc)}]}
    else:
        payload = {"valid": result.valid, "findings": [item.as_dict() for item in result.findings]}

    rendered = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.write_text(rendered, encoding="utf-8", newline="\n")
    print(rendered, end="")
    return 0 if payload["valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
