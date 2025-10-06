# Site — README

This folder contains your static portfolio site. Use the documents and scripts here to preview locally, add blog posts, and push updates to GitHub/Netlify.

Quick tasks

- Preview locally: open `index.html` in a browser or run a simple local server (PowerShell example below).
- Create a new blog post: use `tools\add-post.ps1` (see that script's header for usage).
- Push the `site/` folder to GitHub on a branch `sam-site-update` using the provided helper script `tools\push-site.ps1`.

Preview locally (PowerShell)

1. Run a simple HTTP server that serves the `site` folder:

```powershell
# from the workspace root (C:\Users\Shamsher)
Set-Location -Path .\site
# If you have Python 3 installed:
python -m http.server 8000
# Then open http://localhost:8000 in your browser

# If Python is not available, PowerShell 5.1 can run a tiny listener (not production):
Add-Type -AssemblyName System.Net.HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()
Write-Output 'Listening http://localhost:8000 ... (Ctrl+C to stop)'
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $path = $req.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }
    $file = Join-Path -Path (Get-Location) -ChildPath $path
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ctx.Response.ContentLength64 = $bytes.Length
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $ctx.Response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
        $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.OutputStream.Close()
}
```

How the push helper works

- `tools\push-site.ps1` will create a new branch `sam-site-update`, commit the `site/` folder (only files under `site/`) and push the branch to your `origin` remote.
- The script does not overwrite `main` or `master`. It creates a branch and pushes — then you can open a PR on GitHub or merge locally.

Security note

- The helper script uses your local Git and HTTPS credentials configured in your environment. Do not paste Personal Access Tokens into scripts. If you use a PAT, prefer `git credential-manager` or ephemeral tokens.

If anything is unclear, tell me and I can tweak the script or make it create a signed commit or include tags.
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
