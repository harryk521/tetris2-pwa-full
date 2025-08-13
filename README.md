# Tetris – Full PWA (GitHub Pages Subpath-safe)

This package contains a full-featured Tetris (Hold, Pause, Sound, Touch) ready for GitHub Pages.

## Deploy
1) Create a GitHub repo (public).  
2) Upload all files in this folder to the repo root.  
3) Settings → Pages → Deploy from a branch → main / (root) → Save.  
4) Open the URL shown at the top (e.g., https://USERNAME.github.io/REPO/).

## Notes
- `manifest.json` uses `start_url: "."` and `scope: "."` for subpath safety.
- `service-worker.js` precaches index/manifest/icons and uses network-first for HTML.
- After first load, the game works offline. Add to Home Screen on mobile for an app-like experience.
