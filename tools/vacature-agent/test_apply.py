import json
import unittest
from pathlib import Path

from apply import load_contact, write_letter

ROOT = Path(__file__).resolve().parent


class ApplyTests(unittest.TestCase):
    def test_letter_mentions_comfyui(self):
        profile = json.loads((ROOT / "profile.json").read_text(encoding="utf-8"))
        contact = load_contact()
        path = write_letter(
            {
                "id": "testcomfyui",
                "title": "AI Engineer",
                "company": "RSC",
                "location": "Panningen",
                "reasons": ["hybride"],
            },
            profile,
            contact,
        )
        text = path.read_text(encoding="utf-8")
        self.assertIn("ComfyUI", text)
        self.assertIn("image generation", text)
        self.assertIn("visuals", text.lower())

    def test_letter_covers_websites_not_only_ai_roles(self):
        profile = json.loads((ROOT / "profile.json").read_text(encoding="utf-8"))
        contact = load_contact()
        path = write_letter(
            {
                "id": "testwebphp",
                "title": "Webdeveloper PHP",
                "company": "Lokaal bureau",
                "location": "Venlo",
                "reasons": ["dichtbij: Venlo", "stack-match"],
            },
            profile,
            contact,
        )
        text = path.read_text(encoding="utf-8")
        self.assertIn("websites", text.lower())
        self.assertIn("PHP", text)
        self.assertIn("Cursor", text)

    def test_letter_apply_recruitment_is_honest(self):
        profile = json.loads((ROOT / "profile.json").read_text(encoding="utf-8"))
        contact = load_contact()
        path = write_letter(
            {
                "id": "testapplyweert",
                "title": "AI Engineer",
                "company": "Apply Recruitment (intermediair)",
                "location": "Weert",
                "contact_name": "Robin Aeissing",
                "reasons": ["dichtbij: Weert", "AI/automatisering"],
            },
            profile,
            contact,
        )
        text = path.read_text(encoding="utf-8")
        self.assertIn("Beste Robin", text)
        self.assertIn("Castorstraat", text)
        self.assertIn("AT-Automation", text)
        self.assertIn("Geen HBO-diploma", text)
        self.assertIn("€4500", text)
        self.assertNotIn("Remote of hybride met thuiswerken is voor mij essentieel", text)


if __name__ == "__main__":
    unittest.main()
