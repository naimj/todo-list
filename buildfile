# Stop script on error
$ErrorActionPreference = "Stop"

# Enable UTF-8 output for proper character and emoji rendering
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Set date and target folder name
$Date = Get-Date -Format "yyyy-MM-dd"
$TargetFolder = "..\demo_$Date"
$branch = "demo"

Write-Host "📦 Starting build for delivery [$Date]"
Write-Host "--------------------------------------"

# Prevent overwriting if target folder exists
if (Test-Path $TargetFolder) {
    Write-Host "❌ Folder '$TargetFolder' already exists. Please remove it or change the date." -ForegroundColor Red
    exit 1
}

# 1️⃣ Checkout and pull latest code from 'demo' branch
Write-Host "➡️ Switching to branch '$branch' and pulling latest changes..."
git checkout $branch | Out-Null
git pull origin $branch | Out-Null

# 2️⃣ Backup existing .env and copy .env.prod
if (Test-Path ".env") {
    $backupEnv = ".env.bak.$Date"
    Copy-Item ".env" $backupEnv -Force
    Write-Host "🛡️  Existing .env backed up to $backupEnv"
}

Write-Host "➡️ Copying .env.prod to .env..."
Copy-Item ".env.prod" ".env" -Force

# 3️⃣ Clear Laravel cache
Write-Host "🧹 Clearing Laravel caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# 4️⃣ Build frontend (Vue)
Write-Host "⚙️ Building frontend..."
npm run build

# 5️⃣ Create target folder
Write-Host "📁 Creating delivery folder: $TargetFolder"
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# 6️⃣ Get items to copy, excluding unnecessary files/folders
$itemsToCopy = Get-ChildItem -Force | Where-Object {
    $_.Name -notin @("node_modules", ".git", ".gitignore", ".gitattributes")
}
$totalItems = $itemsToCopy.Count
$current = 0

# 7️⃣ Copy with progress bar
Write-Host "🚚 Copying files with progress bar..."

foreach ($item in $itemsToCopy) {
    $sourcePath = $item.FullName
    $destinationPath = Join-Path $TargetFolder $item.Name

    # Use robocopy for fast, silent copying
    robocopy $sourcePath $destinationPath /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null

    $current++
    $percent = [math]::Floor(($current / $totalItems) * 100)

    # Display progress bar
    $barWidth = 30
    $filled = [math]::Round($percent * $barWidth / 100)
    $bar = ("#" * $filled).PadRight($barWidth)

    Write-Host ("`r[{0}] {1}% ({2}/{3})" -f $bar, $percent, $current, $totalItems) -NoNewline
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
