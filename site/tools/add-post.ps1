param(
  [Parameter(Mandatory=$true)] [string]$Title,
  [Parameter(Mandatory=$true)] [ValidateSet('exchange','m365','azure','intune')] [string]$Category,
  [Parameter(Mandatory=$true)] [string]$Slug,
  [Parameter(Mandatory=$false)] [string]$Excerpt = ''
)

# Paths
$root = Split-Path -Parent (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
$blogRoot = Join-Path $root '..\blog' | Resolve-Path -Relative
$learnRoot = Join-Path $root '..\blog\learn-with-me' | Resolve-Path -Relative
$categoryDir = Join-Path $learnRoot $Category

# Ensure category directory exists
if (-not (Test-Path $categoryDir)) {
  New-Item -ItemType Directory -Path $categoryDir -Force | Out-Null
}

# Create filename and paths
$filename = "$Slug.html"
$postPath = Join-Path $categoryDir $filename

# Make backup of posts.json and category index
$postsJson = Join-Path $root '..\blog\posts.json'
if (Test-Path $postsJson) { Copy-Item $postsJson "$postsJson.bak" -Force }
$categoryIndex = Join-Path $categoryDir 'index.html'
if (Test-Path $categoryIndex) { Copy-Item $categoryIndex "$categoryIndex.bak" -Force }

# Generate post from template
$template = Join-Path $root 'post-template.html'
if (-not (Test-Path $template)) { Write-Error "Template not found at $template"; exit 1 }

$html = Get-Content $template -Raw
$html = $html -replace '{{TITLE}}', [System.Web.HttpUtility]::HtmlEncode($Title)
$html = $html -replace '{{DATE}}', (Get-Date).ToString('yyyy-MM-dd')
$html = $html -replace '{{EXCERPT}}', [System.Web.HttpUtility]::HtmlEncode($Excerpt)

# Write the new post
$html | Set-Content -Path $postPath -Encoding UTF8
Write-Host "Created post: $postPath"

# Update posts.json
if (-not (Test-Path $postsJson)) { "[]" | Set-Content $postsJson -Encoding UTF8 }
$posts = Get-Content $postsJson -Raw | ConvertFrom-Json
$new = [PSCustomObject]@{
  title = $Title
  url = "learn-with-me/$Category/$filename"
  excerpt = $Excerpt
  category = $Category
  date = (Get-Date).ToString('yyyy-MM-dd')
}
$posts += $new
$posts | ConvertTo-Json -Depth 5 | Set-Content $postsJson -Encoding UTF8
Write-Host "Appended post to posts.json"

# Insert an article snippet into category index (before <!-- Add more Exchange posts here --> or at end)
$snippet = "<article class=\"bg-white/5 p-4 rounded-lg text-white\">`n  <h2 class=\"text-xl font-semibold\"><a href=\"$filename\" class=\"hover:underline\">$Title</a></h2>`n  <p class=\"text-white/80 mt-2\">$Excerpt</p>`n  <p class=\"mt-3\"><a href=\"$filename\" class=\"text-emerald-300 hover:underline\">Read post →</a></p>`n</article>`n"

if (Test-Path $categoryIndex) {
  $catHtml = Get-Content $categoryIndex -Raw
  if ($catHtml -match '<!-- Add more Exchange posts here -->') {
    $catHtml = $catHtml -replace '<!-- Add more Exchange posts here -->', "$snippet`n<!-- Add more Exchange posts here -->"
  } else {
    # append before </section>
    $catHtml = $catHtml -replace '(</section>)', "$snippet`n`$1"
  }
  $catHtml | Set-Content $categoryIndex -Encoding UTF8
  Write-Host "Updated category index: $categoryIndex"
} else {
  # create a simple index for the category
  $catIndexContent = "<!doctype html>`n<html><head><meta charset=\"utf-8\"><title>$Category</title><script src=\"https://cdn.tailwindcss.com\"></script></head><body class=\"bg-gradient-to-b from-slate-900 via-slate-800 to-emerald-900 text-white min-h-screen\">`n<header class=\"max-w-6xl mx-auto p-6 flex justify-between items-center\">`n<a href=\"../../../index.html\" class=\"text-xl font-semibold\">Sam Adhikari</a>`n</header>`n<main class=\"max-w-4xl mx-auto p-6\">`n<h1 class=\"text-3xl font-bold mb-4\">$Category — Learn with Me</h1>`n<section>`n$snippet`n</section>`n</main>`n</body></html>"
  $catIndexContent | Set-Content $categoryIndex -Encoding UTF8
  Write-Host "Created category index: $categoryIndex"
}

Write-Host "Done. Open the new post at: blog/learn-with-me/$Category/$filename"
