#!/usr/bin/env python3
"""Fail-fast structural and contract checks for the distributable repository."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LANGS = ("", ".zh-CN", ".ja", ".fr", ".es")


def require(path: str) -> Path:
    result = ROOT / path
    if not result.exists():
        raise AssertionError(f"missing required path: {path}")
    return result


def check_json(path: str) -> None:
    with require(path).open(encoding="utf-8") as stream:
        json.load(stream)


def main() -> int:
    for suffix in LANGS:
        require(f"README{suffix}.md")
        require(f"office-copilot/README{suffix}.md")
        require(f"docs/architecture{suffix}.md")
        require(f"skills/README{suffix}.md")

    for path in (
        "LICENSE",
        "THIRD_PARTY_NOTICES.md",
        "skills/office-copilot-ppt-orchestrator/SKILL.md",
        "skills/ppt-html-vba-compiler/SKILL.md",
        "skills/ppt-html-vba-compiler/vba/PptHtmlCompiler.bas",
        "skills/ppt-html-vba-compiler/vba/vendor/JsonConverter.bas",
        "skills/ppt-html-vba-compiler/vba/vendor/Dictionary.cls",
    ):
        require(path)

    for path in (
        "ppt-html/schema/ppt-html-schema-1.0.0.json",
        "ppt-html/mapping/object-mapping-1.0.0.json",
        "shared-library-template/PPT-Skill-Library/Published/Current/release-manifest.json",
        "skills/ppt-html-vba-compiler/assets/ppt-html-schema.json",
        "skills/ppt-html-vba-compiler/assets/object-mapping.json",
    ):
        check_json(path)

    for skill in ("office-copilot-ppt-orchestrator", "ppt-html-vba-compiler"):
        text = require(f"skills/{skill}/SKILL.md").read_text(encoding="utf-8")
        match = re.match(r"---\s*\nname:\s*([^\n]+)", text)
        if not match or match.group(1).strip() != skill:
            raise AssertionError(f"Skill name does not match directory: {skill}")

    for markdown in ROOT.rglob("*.md"):
        text = markdown.read_text(encoding="utf-8")
        for target in re.findall(r"\[[^\]]*\]\(([^)]+)\)", text):
            clean = target.split("#", 1)[0].strip()
            if not clean or "://" in clean or clean.startswith("mailto:"):
                continue
            linked = (markdown.parent / clean).resolve()
            if not linked.exists():
                raise AssertionError(f"broken local link in {markdown.relative_to(ROOT)}: {target}")

    forbidden = (str(ROOT), "gh" + "p_", "github" + "_pat_", "BEGIN OPENSSH " + "PRIVATE KEY")
    for path in ROOT.rglob("*"):
        if path.is_file() and path.suffix.lower() in {".md", ".txt", ".json", ".yaml", ".yml", ".py", ".ps1", ".bas", ".cls"}:
            text = path.read_text(encoding="utf-8", errors="ignore")
            for marker in forbidden:
                if marker in text:
                    raise AssertionError(f"private or machine-local marker in {path.relative_to(ROOT)}: {marker}")

    prompt_root = ROOT / "office-copilot"
    for path in list(prompt_root.glob("*-agent-generator.txt")) + list((prompt_root / "instructions").glob("*.txt")):
        text = path.read_text(encoding="utf-8")
        if len(text) > 8_000:
            raise AssertionError(f"Agent text exceeds 8000 characters: {path}")

    subprocess.run(
        [sys.executable, str(ROOT / "skills/ppt-html-vba-compiler/scripts/validate_ppt_html.py"),
         str(ROOT / "skills/ppt-html-vba-compiler/tests/fixtures/sample-deck.html")],
        check=True,
    )
    print("Repository validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
