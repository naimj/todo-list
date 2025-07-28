#!/bin/bash

# 🚨 Stop en cas d'erreur
set -e

# 📍 Variables
DATE=$(date +%F)
DEST="../demo_$DATE"

echo "📦 Création du livrable demo pour le $DATE"
echo "-------------------------------"

# 1️⃣ Aller sur la branche demo et pull
echo "➡️ Passage sur la branche 'demo' et récupération des dernières modifications..."
git checkout demo
git pull origin demo

# 2️⃣ Copier .env.prod dans .env
echo "➡️ Copie de .env.prod vers .env..."
cp .env.prod .env

# 3️⃣ Nettoyage des caches Laravel
echo "🧹 Nettoyage des caches Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# 4️⃣ Build du frontend
echo "⚙️ Compilation du frontend..."
npm run build

# 5️⃣ Création du dossier de livrable
echo "📁 Création du dossier '$DEST'..."
mkdir -p "$DEST"

# 6️⃣ Copie des fichiers
echo "📦 Copie des fichiers (sans node_modules, .git, .gitignore, .gitattributes)..."
cp -r . "$DEST"

# Suppression manuelle des dossiers/fichiers exclus
rm -rf "$DEST/node_modules"
rm -rf "$DEST/.git"
rm -f "$DEST/.gitignore"
rm -f "$DEST/.gitattributes"

echo "✅ Livrable créé avec succès dans : $DEST"
