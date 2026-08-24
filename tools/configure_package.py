#!/usr/bin/env python3
"""Create a tenant-configured Office Copilot deployment bundle."""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path
from urllib.parse import urlparse


PLACEHOLDER = "{{SHARED_LIBRARY_ROOT_URL}}"
TEXT_SUFFIXES = {".txt", ".md", ".json", ".csv", ".yaml", ".yml", ".html"}


def validate_root_url(value: str) -> str:
    value = value.rstrip("/")
    parsed = urlparse(value)
    if parsed.scheme != "https" or not parsed.netloc:
        raise argparse.ArgumentTypeError("root URL must be an absolute https URL")
    if not value.lower().endswith("ppt-skill-library"):
        raise argparse.ArgumentTypeError(
            "root URL must end with PPT-Skill-Library so derived paths stay predictable"
        )
    return value


def replace_in_tree(root: Path, root_url: str) -> int:
    changed = 0
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        text = path.read_text(encoding="utf-8")
        if PLACEHOLDER in text:
            path.write_text(text.replace(PLACEHOLDER, root_url), encoding="utf-8", newline="\n")
            changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root-url", required=True, type=validate_root_url)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    if output.exists():
        raise SystemExit(f"output already exists: {output}")

    output.mkdir(parents=True)
    shutil.copytree(repo_root / "office-copilot", output / "office-copilot")
    shutil.copytree(
        repo_root / "shared-library-template",
        output / "shared-folder-template",
    )
    shutil.copy2(repo_root / "office-copilot" / "README.md", output / "deployment.md")

    changed = replace_in_tree(output, args.root_url)
    if changed == 0:
        raise SystemExit("configuration placeholder was not found")
    remaining = [
        str(path)
        for path in output.rglob("*")
        if path.is_file()
        and path.suffix.lower() in TEXT_SUFFIXES
        and PLACEHOLDER in path.read_text(encoding="utf-8")
    ]
    if remaining:
        raise SystemExit(f"unresolved placeholders remain: {remaining}")

    print(f"Configured bundle created at {output}")
    print(f"Configured {changed} files for {args.root_url}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
