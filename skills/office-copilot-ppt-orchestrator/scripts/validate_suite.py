#!/usr/bin/env python3
"""Validate the standalone Orchestrator Skill package."""

from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path


PLACEHOLDER = "{{SHARED_LIBRARY_ROOT_URL}}"
BEGIN = "--- BEGIN EXACT INSTRUCTIONS ---"
END = "--- END EXACT INSTRUCTIONS ---"
AGENTS = {
    "ppt-authoring": "ppt-authoring-agent",
    "skill-curator": "skill-curator-agent",
    "ppt-qa": "ppt-qa-agent",
}
REQUIRED = [
    "SKILL.md",
    "agents/openai.yaml",
    "references/deployment.md",
    "references/governance.md",
    "references/scheduled-update-flow.md",
    "references/ppt-html-contract.md",
    "references/object-mapping.md",
    "references/qa-contract.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/release-manifest.json",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/ppt-html-schema.json",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/design-standard.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/object-mapping.json",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/qa-rubric.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/style-catalog.json",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/style-matching.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/style-pack-contract.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/chart-design-standard.md",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/style-gallery.html",
    "assets/shared-folder-template/PPT-Skill-Library/Published/Current/chart-slide-template.html",
    "assets/shared-folder-template/PPT-Skill-Library/Registry/source-watchlist.csv",
    "assets/examples/sample-deck/deck.html",
    "assets/examples/sample-deck/build-manifest.json",
]


def extract_exact_instructions(text: str, path: Path, errors: list[str]) -> str:
    if text.count(BEGIN) != 1 or text.count(END) != 1:
        errors.append(f"{path}: expected exactly one instruction marker pair")
        return ""
    return text.split(BEGIN, 1)[1].split(END, 1)[0].strip()


def read_json(path: Path, errors: list[str]):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"{path}: invalid JSON: {exc}")
        return None


def validate_embedded_model(path: Path, manifest: dict | None, errors: list[str]) -> list[str]:
    match = re.search(
        r'<script id="ppt-model" type="application/json">\s*(.*?)\s*</script>',
        path.read_text(encoding="utf-8"), flags=re.S,
    )
    if not match:
        errors.append(f"{path}: no embedded ppt-model")
        return []
    try:
        model = json.loads(match.group(1))
    except Exception as exc:
        errors.append(f"{path}: embedded ppt-model is invalid JSON: {exc}")
        return []
    if model.get("slideSize") != {"width": 960, "height": 540}:
        errors.append(f"{path}: slide size is not 960x540")
    if manifest and model.get("schemaVersion") != manifest.get("pptHtmlSchemaVersion"):
        errors.append(f"{path}: schema version does not match Current")
    slides = model.get("slides", [])
    slide_ids = [slide.get("id") for slide in slides]
    if not slides or None in slide_ids or len(slide_ids) != len(set(slide_ids)):
        errors.append(f"{path}: missing or duplicate slide IDs")
    supported = set(manifest.get("supportedObjectTypes", [])) if manifest else set()
    allowed_fidelity = {"exact-native", "native-approximation", "grouped-native", "svg-fallback", "raster-fallback", "unsupported"}
    ids: list[str] = []
    for slide in slides:
        for obj in slide.get("objects", []):
            ids.append(obj.get("id"))
            if obj.get("type") not in supported:
                errors.append(f"{path}: unsupported object type: {obj.get('type')}")
            if obj.get("fidelity") not in allowed_fidelity:
                errors.append(f"{path}: invalid fidelity: {obj.get('id')}")
            bounds = obj.get("bounds", {})
            values = [bounds.get(key) for key in ("x", "y", "w", "h")]
            if not all(isinstance(value, (int, float)) for value in values):
                errors.append(f"{path}: invalid bounds: {obj.get('id')}")
            elif values[0] < 0 or values[1] < 0 or values[2] <= 0 or values[3] <= 0 or values[0] + values[2] > 960 or values[1] + values[3] > 540:
                errors.append(f"{path}: object outside slide bounds: {obj.get('id')}")
            if not isinstance(obj.get("z"), int) or obj.get("z") < 0:
                errors.append(f"{path}: invalid z-order: {obj.get('id')}")
    if None in ids or len(ids) != len(set(ids)):
        errors.append(f"{path}: missing or duplicate object IDs")
    return ids


def main() -> int:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
    errors: list[str] = []
    for relative in REQUIRED:
        if not (root / relative).is_file():
            errors.append(f"missing required file: {relative}")

    for path in root.rglob("*"):
        if not path.is_file() or any(part in {"dist", "__pycache__"} for part in path.parts):
            continue
        if path.suffix.lower() in {".md", ".txt", ".json", ".csv", ".yaml", ".yml", ".html", ".py"}:
            text = path.read_text(encoding="utf-8")
            if any(marker in text for marker in ("[TO" + "DO", "TO" + "DO:")):
                errors.append(f"unfinished scaffold marker: {path.relative_to(root)}")

    for generator_stem, instruction_stem in AGENTS.items():
        generator = root / "office-copilot" / f"{generator_stem}-agent-generator.txt"
        instruction = root / "office-copilot" / "instructions" / f"{instruction_stem}-instructions.txt"
        if not generator.is_file() or not instruction.is_file():
            errors.append(f"missing agent pair for {generator_stem}")
            continue
        generated_text = extract_exact_instructions(generator.read_text(encoding="utf-8"), generator, errors)
        direct_text = instruction.read_text(encoding="utf-8").strip()
        if generated_text != direct_text:
            errors.append(f"generator and direct instructions differ: {generator_stem}")
        if len(direct_text) > 8000:
            errors.append(f"instructions exceed 8,000 characters: {generator_stem} ({len(direct_text)})")
        if PLACEHOLDER not in generator.read_text(encoding="utf-8") or PLACEHOLDER not in direct_text:
            errors.append(f"shared-library placeholder missing: {generator_stem}")

    for path in root.rglob("*.json"):
        if "dist" not in path.parts:
            read_json(path, errors)
    for path in root.rglob("*.csv"):
        if "dist" in path.parts:
            continue
        try:
            with path.open(encoding="utf-8", newline="") as handle:
                rows = list(csv.reader(handle))
            if not rows or not rows[0] or any(not value for value in rows[0]):
                errors.append(f"CSV header is missing or empty: {path.relative_to(root)}")
        except Exception as exc:
            errors.append(f"invalid CSV {path.relative_to(root)}: {exc}")

    current = root / "assets" / "shared-folder-template" / "PPT-Skill-Library" / "Published" / "Current"
    manifest = read_json(current / "release-manifest.json", errors)
    schema = read_json(current / "ppt-html-schema.json", errors)
    catalog = read_json(current / "style-catalog.json", errors)
    if manifest:
        for filename in manifest.get("files", []):
            if not (current / filename).is_file():
                errors.append(f"release manifest references missing file: {filename}")
    if manifest and schema:
        schema_version = schema.get("properties", {}).get("schemaVersion", {}).get("const")
        if schema_version != manifest.get("pptHtmlSchemaVersion"):
            errors.append("schema const does not match release manifest")
    if catalog:
        pack_ids = [pack.get("id") for pack in catalog.get("packs", [])]
        if len(pack_ids) < 8 or None in pack_ids or len(pack_ids) != len(set(pack_ids)):
            errors.append("style catalog must contain at least eight unique pack IDs")
        if "chart" not in catalog.get("sharedLayouts", []):
            errors.append("style catalog must include the shared chart layout")
        for pack in catalog.get("packs", []):
            tokens = pack.get("tokens", {})
            required_chart_tokens = {"categorical", "sequential", "diverging", "semantic", "grid"}
            if not required_chart_tokens.issubset(tokens):
                errors.append(f"style pack lacks chart tokens: {pack.get('id')}")

    sample_html = root / "assets" / "examples" / "sample-deck" / "deck.html"
    sample_manifest_path = root / "assets" / "examples" / "sample-deck" / "build-manifest.json"
    if sample_html.is_file():
        object_ids = validate_embedded_model(sample_html, manifest, errors)
        sample_manifest = read_json(sample_manifest_path, errors)
        if sample_manifest and sample_manifest.get("objectCount") != len(object_ids):
            errors.append("sample build-manifest objectCount is incorrect")
    chart_template = current / "chart-slide-template.html"
    if chart_template.is_file():
        validate_embedded_model(chart_template, manifest, errors)

    if errors:
        print("Suite validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Suite validation passed")
    for generator_stem, instruction_stem in AGENTS.items():
        length = len((root / "office-copilot" / "instructions" / f"{instruction_stem}-instructions.txt").read_text(encoding="utf-8").strip())
        print(f"- {generator_stem} instructions: {length}/8000 characters")
    print(f"- required files: {len(REQUIRED)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
