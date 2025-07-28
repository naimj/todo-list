# Stop script on error
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Date = Get-Date -Format "yyyy-MM-dd"
$TargetFolder = "..\demo_$Date"
$branch = "demo"

Write-Host "📦 Starting build for delivery [$Date]"
Write-Host "--------------------------------------"

# Stop if target already exists
if (Test-Path $TargetFolder) {
    Write-Host "❌ Folder '$TargetFolder' already exists. Please delete it or change the date." -ForegroundColor Red
    exit 1
}

# Checkout and pull
Write-Host "➡️ Switching to '$branch' branch and pulling updates..."
git checkout $branch | Out-Null
git pull origin $branch | Out-Null

# Backup .env and copy .env.prod
if (Test-Path ".env") {
    $backup = ".env.bak.$Date"
    Copy-Item ".env" $backup -Force
    Write-Host "🛡️  Backed up .env to $backup"
}
Write-Host "➡️ Copying .env.prod to .env..."
Copy-Item ".env.prod" ".env" -Force

# Clear Laravel cache
Write-Host "🧹 Clearing Laravel caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# Build frontend
Write-Host "⚙️ Building frontend..."
npm run build

# Create target folder
Write-Host "📁 Creating delivery folder: $TargetFolder"
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# Step 1: Copy files (not folders) from root
$filesToCopy = Get-ChildItem -File -Force | Where-Object {
    $_.Name -notin @(".gitignore", ".gitattributes")
}

Write-Host "📄 Copying root files..."
foreach ($file in $filesToCopy) {
    Copy-Item $file.FullName -Destination (Join-Path $TargetFolder $file.Name) -Force
}

# Step 2: Copy folders (excluding node_modules and .git)
$dirsToCopy = Get-ChildItem -Directory -Force | Where-Object {
    $_.Name -notin @("node_modules", ".git")
}

$total = $dirsToCopy.Count
$current = 0

Write-Host "📁 Copying folders with progress bar..."
foreach ($dir in $dirsToCopy) {
    $source = $dir.FullName
    $destination = Join-Path $TargetFolder $dir.Name

    robocopy $source $destination /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null

    $current++
    $percent = [math]::Floor(($current / $total) * 100)
    $barLength = 30
    $filled = [math]::Round($percent * $barLength / 100)
    $bar = ("#" * $filled).PadRight($barLength)

    Write-Host ("`r[{0}] {1}% ({2}/{3})" -f $bar, $percent, $current, $total) -NoNewline
}

Write-Host "`n✅ Delivery folder created successfully: $TargetFolder"

////
Ouvre PowerShell

Navigue jusqu'au dossier de ton projet Laravel :

powershell
Copier
Modifier
cd C:\chemin\vers\mon-projet
Lance :

powershell
Copier
Modifier
powershell -ExecutionPolicy Bypass -File build_demo.ps1
