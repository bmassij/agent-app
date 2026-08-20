import unittest

from score import REJECT, KEEP, score_job


PROFILE = {
    "min_freelance_eur": 55,
    "nearby": ["Roermond", "Venlo", "Elsloo", "Panningen", "Dongen", "Heerlen"],
    "far_office_reject": ["Amsterdam", "Rotterdam", "Den Haag", "Utrecht", "Groningen"],
    "roles_want": ["AI Engineer", "Full Stack", "Webdeveloper"],
}


class ScoreTests(unittest.TestCase):
    def test_remote_ai_kept(self):
        job = {
            "title": "AI Engineer Next.js",
            "location": "Nederland",
            "work_mode": "100% remote",
            "summary": "LLM RAG TypeScript Cursor",
            "url": "https://example.com/a",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], KEEP)
        self.assertGreaterEqual(r["score"], 40)

    def test_amsterdam_office_rejected(self):
        job = {
            "title": "Frontend Developer",
            "location": "op locatie Amsterdam",
            "work_mode": "kantoor 5 dagen",
            "summary": "React",
            "url": "https://example.com/b",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], REJECT)

    def test_stage_rejected(self):
        job = {
            "title": "AI stage",
            "location": "Venlo",
            "summary": "internship remote",
            "url": "https://example.com/c",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], REJECT)

    def test_elsloo_remote_first_kept(self):
        job = {
            "title": "Stack Developer Next.js PHP",
            "company": "ten50",
            "location": "Elsloo",
            "work_mode": "remote-first thuiswerk",
            "summary": "React TypeScript webdeveloper",
            "url": "https://example.com/d",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], KEEP)

    def test_genips_fully_remote_beats_randstad_hybrid(self):
        remote = score_job(
            {
                "title": "Full Stack Developer TypeScript",
                "location": "100% remote",
                "work_mode": "altijd remote",
                "summary": "Next.js React",
                "url": "https://example.com/g",
            },
            PROFILE,
        )
        hybrid_far = score_job(
            {
                "title": "AI Engineer Next.js",
                "location": "Rotterdam hybride",
                "work_mode": "hybride thuiswerken",
                "summary": "TypeScript LLM",
                "url": "https://example.com/h",
            },
            PROFILE,
        )
        self.assertEqual(remote["decision"], KEEP)
        self.assertGreater(remote["score"], hybrid_far["score"])

    def test_low_hourly_rate_rejected(self):
        job = {
            "title": "WooCommerce developer remote",
            "summary": "€30 per uur TypeScript",
            "location": "Remote",
            "work_mode": "remote",
            "url": "https://example.com/e",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], REJECT)

    def test_remote_opties_is_not_fully_remote(self):
        job = {
            "title": "AI Software Engineer",
            "company": "Bonsai",
            "location": "Rotterdam hybride, remote-opties",
            "work_mode": "hybride remote",
            "summary": "Python TypeScript Next.js, vanaf Roermond te bereiken",
            "url": "https://example.com/bonsai",
        }
        r = score_job(job, PROFILE)
        self.assertNotIn("remote/thuiswerk", r["reasons"])
        self.assertTrue(any("ver" in x for x in r["reasons"]))

    def test_summary_roermond_does_not_count_as_nearby_office(self):
        job = {
            "title": "Frontend Developer React",
            "location": "Rotterdam",
            "work_mode": "kantoor 5 dagen",
            "summary": "Pendelen vanaf Roermond mogelijk",
            "url": "https://example.com/far",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], REJECT)

    def test_dongen_hybrid_counts_as_nearby(self):
        job = {
            "title": "AI Engineer Laravel & Python",
            "location": "Dongen hybride",
            "work_mode": "hybride thuiswerken",
            "summary": "n8n LLM, ~50 min vanaf Roermond",
            "url": "https://example.com/follo",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], KEEP)
        self.assertTrue(any("Dongen" in x for x in r["reasons"]))
        self.assertFalse(any("Roermond" in x for x in r["reasons"]))

    def test_comfyui_remote_counts_as_ai_match(self):
        job = {
            "title": "Full Stack Developer Python",
            "location": "100% remote",
            "work_mode": "altijd remote",
            "summary": "ComfyUI image generation workflows, TypeScript",
            "url": "https://example.com/comfy",
        }
        r = score_job(job, PROFILE)
        self.assertEqual(r["decision"], KEEP)
        self.assertIn("AI/automatisering", r["reasons"])


if __name__ == "__main__":
    unittest.main()
