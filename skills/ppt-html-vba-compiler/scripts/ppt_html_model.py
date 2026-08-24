"""Deterministic PPT-HTML model loading and validation."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


MODEL_RE = re.compile(
    r'<script\s+[^>]*id=["\']ppt-model["\'][^>]*>\s*(.*?)\s*</script>',
    re.IGNORECASE | re.DOTALL,
)
SUPPORTED_TYPES = {"shape", "text", "image", "svg", "line", "connector", "table", "chart", "group"}
FIDELITY = {"exact-native", "native-approximation", "grouped-native", "svg-fallback", "raster-fallback", "unsupported"}


@dataclass
class Finding:
    severity: str
    code: str
    message: str
    slide_id: str | None = None
    object_id: str | None = None

    def as_dict(self) -> dict[str, Any]:
        return {
            "severity": self.severity,
            "code": self.code,
            "message": self.message,
            "slideId": self.slide_id,
            "objectId": self.object_id,
        }


@dataclass
class ValidationResult:
    model: dict[str, Any] | None
    findings: list[Finding] = field(default_factory=list)

    @property
    def valid(self) -> bool:
        return not any(item.severity in {"BLOCKER", "HIGH"} for item in self.findings)


def load_model(html_path: Path) -> dict[str, Any]:
    html = html_path.read_text(encoding="utf-8")
    match = MODEL_RE.search(html)
    if not match:
        raise ValueError("deck.html does not contain script#ppt-model")
    model = json.loads(match.group(1))
    if not isinstance(model, dict):
        raise ValueError("ppt-model must be a JSON object")
    return model


def _number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def validate_model(model: dict[str, Any], html_path: Path) -> ValidationResult:
    findings: list[Finding] = []
    schema_version = model.get("schemaVersion")
    if not isinstance(schema_version, str) or schema_version.split(".", 1)[0] != "1":
        findings.append(Finding("BLOCKER", "SCHEMA_MAJOR", f"Unsupported schema version: {schema_version!r}"))

    if model.get("slideSize") != {"width": 960, "height": 540}:
        findings.append(Finding("BLOCKER", "SLIDE_SIZE", "slideSize must be exactly 960 x 540"))

    slides = model.get("slides")
    if not isinstance(slides, list) or not slides:
        findings.append(Finding("BLOCKER", "SLIDES", "slides must be a non-empty array"))
        return ValidationResult(model, findings)

    slide_ids: set[str] = set()
    object_ids: set[str] = set()
    object_types: dict[str, str] = {}
    group_children: list[tuple[str, str, list[Any]]] = []

    for slide in slides:
        if not isinstance(slide, dict):
            findings.append(Finding("BLOCKER", "SLIDE_OBJECT", "Every slide must be an object"))
            continue
        slide_id = slide.get("id")
        if not isinstance(slide_id, str) or not slide_id:
            findings.append(Finding("BLOCKER", "SLIDE_ID", "Slide ID is missing"))
            slide_id = None
        elif slide_id in slide_ids:
            findings.append(Finding("BLOCKER", "SLIDE_ID_DUPLICATE", f"Duplicate slide ID: {slide_id}", slide_id))
        else:
            slide_ids.add(slide_id)

        objects = slide.get("objects")
        if not isinstance(objects, list):
            findings.append(Finding("BLOCKER", "OBJECTS", "Slide objects must be an array", slide_id))
            continue

        z_values: set[int] = set()
        for obj in objects:
            if not isinstance(obj, dict):
                findings.append(Finding("BLOCKER", "OBJECT", "Every object must be a JSON object", slide_id))
                continue
            object_id = obj.get("id")
            object_type = obj.get("type")
            if not isinstance(object_id, str) or not object_id:
                findings.append(Finding("BLOCKER", "OBJECT_ID", "Object ID is missing", slide_id))
                object_id = None
            elif object_id in object_ids:
                findings.append(Finding("BLOCKER", "OBJECT_ID_DUPLICATE", f"Duplicate object ID: {object_id}", slide_id, object_id))
            else:
                object_ids.add(object_id)
                if isinstance(object_type, str):
                    object_types[object_id] = object_type

            if object_type not in SUPPORTED_TYPES:
                findings.append(Finding("BLOCKER", "OBJECT_TYPE", f"Unsupported object type: {object_type!r}", slide_id, object_id))

            bounds = obj.get("bounds")
            if not isinstance(bounds, dict) or not all(_number(bounds.get(k)) for k in ("x", "y", "w", "h")):
                findings.append(Finding("BLOCKER", "BOUNDS", "Object requires numeric x, y, w, h bounds", slide_id, object_id))
            else:
                x, y, w, h = (bounds[k] for k in ("x", "y", "w", "h"))
                if w <= 0 or h <= 0:
                    findings.append(Finding("BLOCKER", "BOUNDS_SIZE", "Object width and height must be positive", slide_id, object_id))
                if x < 0 or y < 0 or x + w > 960 or y + h > 540:
                    findings.append(Finding("HIGH", "BOUNDS_SLIDE", "Object extends outside the 960 x 540 slide", slide_id, object_id))

            z = obj.get("z")
            if not isinstance(z, int) or isinstance(z, bool) or z < 0:
                findings.append(Finding("BLOCKER", "Z_ORDER", "Object z must be a non-negative integer", slide_id, object_id))
            elif z in z_values:
                findings.append(Finding("MEDIUM", "Z_ORDER_DUPLICATE", f"Multiple objects use z={z}", slide_id, object_id))
            else:
                z_values.add(z)

            fidelity = obj.get("fidelity")
            if fidelity not in FIDELITY:
                findings.append(Finding("BLOCKER", "FIDELITY", f"Invalid fidelity class: {fidelity!r}", slide_id, object_id))
            if fidelity == "unsupported":
                findings.append(Finding("BLOCKER", "UNSUPPORTED_DECLARED", "Object is explicitly unsupported", slide_id, object_id))
            if fidelity in {"native-approximation", "grouped-native", "svg-fallback", "raster-fallback"} and not obj.get("fallbackReason"):
                findings.append(Finding("MEDIUM", "FALLBACK_REASON", "Non-exact object should declare fallbackReason", slide_id, object_id))

            if object_type in {"image", "svg"}:
                asset = obj.get("asset")
                if not isinstance(asset, str) or not asset:
                    findings.append(Finding("BLOCKER", "ASSET", "Image/SVG object requires an asset path", slide_id, object_id))
                elif re.match(r"^[a-z]+://", asset, re.I):
                    findings.append(Finding("BLOCKER", "REMOTE_ASSET", "Compiler accepts packaged local assets only", slide_id, object_id))
                elif not (html_path.parent / asset).resolve().is_file():
                    findings.append(Finding("HIGH", "ASSET_MISSING", f"Asset not found: {asset}", slide_id, object_id))

            if object_type == "chart":
                chart = obj.get("chart")
                if not isinstance(chart, dict) or not isinstance(chart.get("categories"), list) or not isinstance(chart.get("series"), list):
                    findings.append(Finding("BLOCKER", "CHART_DATA", "Chart requires categories and series arrays", slide_id, object_id))

            if object_type == "table":
                table = obj.get("table")
                if not isinstance(table, dict) or not isinstance(table.get("rows"), list) or not table.get("rows"):
                    findings.append(Finding("BLOCKER", "TABLE_DATA", "Table requires a non-empty rows array", slide_id, object_id))

            if object_type == "group":
                children = obj.get("children")
                if not isinstance(children, list) or len(children) < 2:
                    findings.append(Finding("BLOCKER", "GROUP_CHILDREN", "Group requires at least two child IDs", slide_id, object_id))
                else:
                    group_children.append((slide_id or "", object_id or "", children))

    for slide_id, group_id, children in group_children:
        for child in children:
            if child not in object_ids:
                findings.append(Finding("BLOCKER", "GROUP_CHILD_MISSING", f"Group child does not exist: {child}", slide_id, group_id))
            elif object_types.get(child) == "group":
                findings.append(Finding("MEDIUM", "NESTED_GROUP", f"Nested group requires careful regression testing: {child}", slide_id, group_id))

    return ValidationResult(model, findings)


def build_plan(model: dict[str, Any], html_path: Path) -> dict[str, Any]:
    slides = []
    for slide in model["slides"]:
        objects = []
        for obj in sorted(slide["objects"], key=lambda item: item["z"]):
            record = {
                "id": obj["id"],
                "type": obj["type"],
                "bounds": obj["bounds"],
                "z": obj["z"],
                "fidelity": obj["fidelity"],
                "nativeFactory": {
                    "shape": "Shapes.AddShape",
                    "text": "Shapes.AddTextbox",
                    "image": "Shapes.AddPicture",
                    "svg": "Shapes.AddPicture",
                    "line": "Shapes.AddLine",
                    "connector": "Shapes.AddConnector",
                    "table": "Shapes.AddTable",
                    "chart": "Shapes.AddChart2",
                    "group": "ShapeRange.Group",
                }[obj["type"]],
            }
            if obj["type"] in {"image", "svg"}:
                record["resolvedAsset"] = str((html_path.parent / obj["asset"]).resolve())
            if obj["type"] == "shape" and "text" in obj:
                record["containedText"] = True
                record["powerPointObjectCount"] = 1
            objects.append(record)
        slides.append({"id": slide["id"], "objects": objects})

    return {
        "schemaVersion": model["schemaVersion"],
        "standardVersion": model["standardVersion"],
        "minimumCompilerVersion": model["minimumCompilerVersion"],
        "sourceHtml": html_path.name,
        "sourceSha256": hashlib.sha256(html_path.read_bytes()).hexdigest(),
        "slideSize": model["slideSize"],
        "slideCount": len(slides),
        "objectCount": sum(len(slide["objects"]) for slide in slides),
        "slides": slides,
    }
