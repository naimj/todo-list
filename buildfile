# Stop en cas d'erreur
$ErrorActionPreference = "Stop"

# 📅 Date pour le dossier
$Date = Get-Date -Format "yyyy-MM-dd"
$Dest = "..\demo_$Date"

Write-Host "📦 Création du livrable demo pour le $Date"
Write-Host "-------------------------------"

# 1️⃣ Git checkout + pull
Write-Host "➡️ Passage sur la branche 'demo' et pull..."
git checkout demo
git pull origin demo

# 2️⃣ Copier .env.prod
Write-Host "➡️ Copie de .env.prod vers .env..."
Copy-Item ".env.prod" -Destination ".env" -Force

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

# 5️⃣ Création dossier cible
Write-Host "📁 Création du dossier $Dest"
New-Item -ItemType Directory -Path $Dest -Force | Out-Null

# 6️⃣ Copier les fichiers (exclure node_modules, .git, .gitignore, .gitattributes)
Write-Host "🚀 Copie rapide avec exclusions via robocopy..."

robocopy . $Dest /E /XD node_modules .git /XF .gitignore .gitattributes

Write-Host ""
Write-Host "✅ Livrable créé avec succès dans : $Dest"

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
