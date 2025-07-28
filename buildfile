# Stop on error
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Variables
$Date = Get-Date -Format "yyyy-MM-dd"
$FolderName = "demo_$Date"
$TargetFolder = "..\$FolderName"
$ZipFile = "..\$FolderName.zip"
$branch = "demo"

Write-Host "📦 Starting delivery build for [$Date]"
Write-Host "----------------------------------------"

# Check if folder or zip already exist
if (Test-Path $TargetFolder -or (Test-Path $ZipFile)) {
    Write-Host "❌ A folder or zip named '$FolderName' already exists. Remove it or use another date." -ForegroundColor Red
    exit 1
}

# Git checkout + pull
Write-Host "➡️ Switching to branch '$branch' and pulling latest changes..."
git checkout $branch | Out-Null
git pull origin $branch | Out-Null

# Copy .env.prod to .env
Write-Host "➡️ Copying .env.prod to .env..."
Copy-Item ".env.prod" ".env" -Force

# Laravel cache cleanup
Write-Host "🧹 Clearing Laravel caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# Frontend build
Write-Host "⚙️ Building frontend..."
npm run build

# Create delivery folder
Write-Host "📁 Creating target folder: $TargetFolder"
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# Copy root files
Write-Host "📄 Copying root-level files..."
$filesToCopy = Get-ChildItem -File -Force | Where-Object {
    $_.Name -notin @(".gitignore", ".gitattributes")
}
foreach ($file in $filesToCopy) {
    Copy-Item $file.FullName -Destination (Join-Path $TargetFolder $file.Name) -Force
}

# Copy folders
Write-Host "📁 Copying folders with progress bar..."
$dirsToCopy = Get-ChildItem -Directory -Force | Where-Object {
    $_.Name -notin @("node_modules", ".git")
}
$total = $dirsToCopy.Count
$current = 0

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

Write-Host "`n📦 Creating ZIP archive: $ZipFile..."
Compress-Archive -Path "$TargetFolder\*" -DestinationPath $ZipFile -Force

# Optional: delete folder after zip (uncomment to enable)
# Remove-Item -Recurse -Force $TargetFolder
# Write-Host "🗑️ Deleted temporary folder after zip."

Write-Host "✅ Delivery ZIP created successfully: $ZipFile"


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
