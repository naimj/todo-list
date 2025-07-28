# ⚠️ Arrêter en cas d'erreur
$ErrorActionPreference = "Stop"

# 📅 Générer le nom du dossier cible
$Date = Get-Date -Format "yyyy-MM-dd"
$Dest = "..\demo_$Date"

Write-Host "📦 Création du livrable demo pour le $Date"
Write-Host "------------------------------------------"

# ❗ Vérifier si le dossier existe déjà
if (Test-Path $Dest) {
    Write-Host "❌ Le dossier '$Dest' existe déjà. Supprime-le d'abord ou change la date." -ForegroundColor Red
    exit 1
}

# 1️⃣ Git : s'assurer qu'on est sur demo et à jour
Write-Host "➡️ Passage sur la branche 'demo' et récupération des modifications..."
git checkout demo | Out-Null
git pull origin demo | Out-Null

# 2️⃣ Sauvegarder .env si existant, puis copier .env.prod
if (Test-Path ".env") {
    $backupName = ".env.bak.$Date"
    Copy-Item ".env" $backupName -Force
    Write-Host "🛡️  Sauvegarde de .env existant : $backupName"
}

Write-Host "➡️ Copie de .env.prod vers .env..."
Copy-Item ".env.prod" ".env" -Force

# 3️⃣ Nettoyage Laravel
Write-Host "🧹 Nettoyage des caches Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# 4️⃣ Build frontend
Write-Host "⚙️ Compilation frontend..."
npm run build

# 5️⃣ Créer le dossier cible
Write-Host "📁 Création du dossier : $Dest"
New-Item -ItemType Directory -Path $Dest -Force | Out-Null

# 6️⃣ Fichiers/répertoires à copier (exclusions)
$items = Get-ChildItem -Force | Where-Object {
    $_.Name -notin @("node_modules", ".git", ".gitignore", ".gitattributes")
}
$total = $items.Count
$count = 0

# 7️⃣ Copie avec barre de progression
Write-Host "🚚 Copie avec barre de progression :"

foreach ($item in $items) {
    $src = $item.FullName
    $dst = Join-Path $Dest $item.Name

    # robocopy avec /E pour récursif et options silencieuses
    robocopy $src $dst /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    $count++
    $progress = [math]::Floor(($count / $total) * 100)

    # Barre de progression simple
    $barLength = 30
    $filled = [math]::Round($progress * $barLength / 100)
    $bar = ("#" * $filled).PadRight($barLength)

    Write-Host ("`r[{0}] {1}% ({2}/{3})" -f $bar, $progress, $count, $total) -NoNewline
}

Write-Host "`n✅ Livrable créé avec succès dans : $Dest"


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
