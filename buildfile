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

# 3️⃣ Nettoyer les caches Laravel
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

echo "📦 Copie des fichiers dans '$DEST' (exclusions : .git, .gitignore, .gitattributes, node_modules)..."
rsync -av \
  --exclude='.git' \
  --exclude='.gitignore' \
  --exclude='.gitattributes' \
  --exclude='node_modules' \
  ./ "$DEST"

echo "✅ Livrable créé avec succès dans : $DEST"
