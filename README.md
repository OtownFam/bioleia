# Japan trip planner — backup

Backup of the `japan-trip-planner` Vercel app (deployed at japan-trip-planner-virid.vercel.app).
The app is normally developed in a Claude Code desktop session and deployed via the Vercel CLI;
this repo holds a copy of the deployed `index.html` so the source survives the laptop.

- `index.html` — the full self-contained app (single file; image assets live only on Vercel).
- `deploy/` — one-off Vercel build bundle used on 2026-07-17 to rebuild the Jul 18 card from a
  cloud session: it re-fetches the previous deployment's HTML + images at build time, applies
  `patch.py`, and emits `public/`.
