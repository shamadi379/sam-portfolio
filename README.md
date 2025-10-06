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
