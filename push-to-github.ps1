# Push to GitHub Script
# Run this after creating your GitHub repository

Write-Host "`n🚀 Push to GitHub" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor DarkGray

# Get GitHub username
$username = Read-Host "Enter your GitHub username"

# Confirm repository name
$repoName = Read-Host "Enter repository name (default: db-migration-toolkit)"
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "db-migration-toolkit"
}

Write-Host "`nℹ️  Repository URL: https://github.com/$username/$repoName" -ForegroundColor Yellow
$confirm = Read-Host "Is this correct? (y/n)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "❌ Cancelled" -ForegroundColor Red
    exit
}

Write-Host "`n📡 Adding remote..." -ForegroundColor Cyan
git remote add origin "https://github.com/$username/$repoName.git"

Write-Host "🔀 Renaming branch to main..." -ForegroundColor Cyan
git branch -M main

Write-Host "⬆️  Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS! Repository pushed to GitHub" -ForegroundColor Green
    Write-Host "🌐 View at: https://github.com/$username/$repoName" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Push failed. Make sure:" -ForegroundColor Red
    Write-Host "  1. You created the repository on GitHub" -ForegroundColor Yellow
    Write-Host "  2. You have proper authentication (PAT or SSH)" -ForegroundColor Yellow
    Write-Host "  3. Repository name matches exactly" -ForegroundColor Yellow
}

Write-Host ""
