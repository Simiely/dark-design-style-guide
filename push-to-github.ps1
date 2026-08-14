# push-to-github.ps1
# One-click push: create repo (if missing) + upload all project files via GitHub Contents API.
# Based on official docs: https://docs.github.com/en/rest/repos/contents
# Usage:  powershell -ExecutionPolicy Bypass -File push-to-github.ps1 -Token ghp_xxx
# Or set env var GH_PAT first and run without -Token.
param(
  [string]$Token = ""
)
$ErrorActionPreference = 'Stop'
if (-not $Token) { $Token = $env:GH_PAT }
if (-not $Token) { Write-Host "No token. Pass -Token ghp_xxx or set env GH_PAT." -ForegroundColor Red; exit 1 }

$owner  = 'Simiely'
$repo   = 'dark-design-style-guide'
$dir    = $PSScriptRoot
$branch = 'main'
$files  = @('dark-homepage-designs.html','dark-homepage-designs.md','README.md','AGENTS.md','DEVELOPMENT.md','CHANGELOG.md')

$headers = @{
  'Authorization'        = "Bearer $Token"
  'Accept'               = 'application/vnd.github+json'
  'User-Agent'           = 'wb-push'
  'X-GitHub-Api-Version' = '2022-11-28'
}

function GH-Get($uri) {
  try { return Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -TimeoutSec 30 }
  catch { return $null }
}
function GH-Post($uri, $body) {
  return Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($body | ConvertTo-Json -Depth 6) -ContentType 'application/json; charset=utf-8' -TimeoutSec 30
}
function GH-Put($uri, $body) {
  return Invoke-RestMethod -Uri $uri -Headers $headers -Method Put -Body ($body | ConvertTo-Json -Depth 6) -ContentType 'application/json; charset=utf-8' -TimeoutSec 120
}

Write-Host "== 1/3 check / create repo =="
$repoUrl  = "https://api.github.com/repos/$owner/$repo"
$existing = GH-Get $repoUrl
if ($existing) {
  Write-Host "repo exists: $($existing.full_name)"
} else {
  $newRepo = GH-Post 'https://api.github.com/user/repos' @{
    name        = $repo
    description = 'Dark design style guide: 28 dark-mode homepage design concepts with layout / components / palettes / CSS vars'
    private     = $false
    auto_init   = $false
  }
  Write-Host "repo created: $($newRepo.full_name)"
}

Write-Host "== 2/3 upload $($files.Count) files =="
foreach ($f in $files) {
  $path = Join-Path $dir $f
  if (-not (Test-Path $path)) { Write-Host "skip (missing): $f"; continue }
  $bytes = [IO.File]::ReadAllBytes($path)
  $b64   = [Convert]::ToBase64String($bytes)
  $contentUrl = "https://api.github.com/repos/$owner/$repo/contents/$f"
  $existing = GH-Get $contentUrl
  $body = @{
    message = "docs: update $f (dark design style guide)"
    content = $b64
    branch  = $branch
  }
  if ($existing) { $body.sha = $existing.sha }
  $r = GH-Put $contentUrl $body
  Write-Host "UPLOADED $f ($($bytes.Length)B) sha=$($r.content.sha.Substring(0,7))"
}

Write-Host "== 3/3 verify =="
$verify = GH-Get "https://api.github.com/repos/$owner/$repo/contents/"
foreach ($item in $verify) { Write-Host "  $($item.type) $($item.name) $($item.size)B" }
Write-Host "DONE: https://github.com/$owner/$repo"
