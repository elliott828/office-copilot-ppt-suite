from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from ppt_html_model import build_plan, load_model, validate_model  # noqa: E402


class PptHtmlValidatorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.html = ROOT / "tests" / "fixtures" / "sample-deck.html"
        cls.model = load_model(cls.html)

    def test_sample_is_valid(self):
        result = validate_model(copy.deepcopy(self.model), self.html)
        self.assertTrue(result.valid, [item.as_dict() for item in result.findings])

    def test_plan_preserves_one_shape_with_contained_text(self):
        plan = build_plan(copy.deepcopy(self.model), self.html)
        self.assertEqual(plan["sourceHtml"], "sample-deck.html")
        card = next(item for item in plan["slides"][0]["objects"] if item["id"] == "kpi-card")
        self.assertEqual(card["nativeFactory"], "Shapes.AddShape")
        self.assertTrue(card["containedText"])
        self.assertEqual(card["powerPointObjectCount"], 1)

    def test_plan_matches_portable_golden_file(self):
        expected = json.loads((ROOT / "tests" / "expected" / "sample-compile-plan.json").read_text(encoding="utf-8"))
        self.assertEqual(build_plan(copy.deepcopy(self.model), self.html), expected)

    def test_unknown_schema_major_fails(self):
        model = copy.deepcopy(self.model)
        model["schemaVersion"] = "2.0.0"
        result = validate_model(model, self.html)
        self.assertFalse(result.valid)
        self.assertIn("SCHEMA_MAJOR", {item.code for item in result.findings})

    def test_duplicate_object_id_fails(self):
        model = copy.deepcopy(self.model)
        duplicate = copy.deepcopy(model["slides"][0]["objects"][0])
        model["slides"][0]["objects"].append(duplicate)
        result = validate_model(model, self.html)
        self.assertFalse(result.valid)
        self.assertIn("OBJECT_ID_DUPLICATE", {item.code for item in result.findings})

    def test_off_slide_object_fails(self):
        model = copy.deepcopy(self.model)
        model["slides"][0]["objects"][0]["bounds"]["x"] = 950
        result = validate_model(model, self.html)
        self.assertFalse(result.valid)
        self.assertIn("BOUNDS_SLIDE", {item.code for item in result.findings})


if __name__ == "__main__":
    unittest.main()
