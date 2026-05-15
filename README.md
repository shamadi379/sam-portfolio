# Shamsher Adhikari — Static Site

This folder contains a single-file static website for Shamsher Adhikari.

Files
- `index.html` — the full site (hero, about, skills, experience, education, contact, footer).

Quick local preview (PowerShell)

1. Open PowerShell and change to this folder:

```powershell
cd C:\Users\Shamsher\site
```

2. Start a simple static server with Python (if Python is installed):

```powershell
python -m http.server 8000
# then open http://localhost:8000 in your browser
```

Or use Node's `serve` via npx (if Node is installed):

```powershell
npx serve -s . -l 3000
# then open http://localhost:3000
```

Notes
- Edit `index.html` to update contact details, links, or images. The displayed name has been updated to "Sam Adhikari".
- The hero image currently loads from a placeholder URL — replace the `src` with a local image (e.g. `images/me.jpg`) and add the file under `images/`.
- The contact form is static by default; to receive messages you'll need to wire it to a form backend or use a service (Formspree, Netlify Forms, etc.).
 - The contact form is now wired to FormSubmit and will forward messages to `shamsherintech@gmail.com`.

If you'd like, I can:
- Add a small Node/Express dev server and a package.json
- Wire the contact form to Formspree or Netlify Forms
- Prepare a deploy config for GitHub Pages, Vercel, or Netlify

Tell me which of the above you'd like next.

GitHub Pages deployment (recommended if Netlify is suspended)

This repository includes a GitHub Actions workflow at `.github/workflows/deploy-site.yml` which publishes the `site/` folder to the `gh-pages` branch automatically when you push to `sam-site-update-from-main` or `main`.

Quick steps:

1. Push your branch to GitHub (example):

	git checkout -B sam-site-update-from-main
	git add .
	git commit -m "Site: update UI"
	git push -u origin sam-site-update-from-main

2. Open the repository on GitHub → Settings → Pages and select the `gh-pages` branch as the source (the workflow will create/update it).

3. After the Actions workflow completes, your site will be live at:

	https://<your-github-username>.github.io/sam-portfolio/

Notes:
- The workflow uses the default GITHUB_TOKEN so no extra secrets are required.
- If you use a custom domain, add it to the Pages settings and create a `CNAME` file in `site/` with the domain.
