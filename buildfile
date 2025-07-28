#!/bin/bash

set -e

DATE=$(date +%F)
DEST="../demo_$DATE"

echo "📦 Création du livrable demo pour le $DATE"
echo "-------------------------------"

# 1️⃣ Git pull sur demo
echo "➡️ Passage sur la branche 'demo' et pull..."
git checkout demo
git pull origin demo

# 2️⃣ Copier .env.prod dans .env
echo "➡️ Copie de .env.prod vers .env..."
cp .env.prod .env

# 3️⃣ Nettoyage Laravel
echo "🧹 Nettoyage des caches Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear

# 4️⃣ Build frontend
echo "⚙️ Compilation frontend..."
npm run build

# 5️⃣ Création du dossier livrable
echo "📁 Création du dossier '$DEST'..."
mkdir -p "$DEST"

# 6️⃣ Préparation à la copie
echo "📦 Préparation de la copie avec barre de progression..."

# Lister les fichiers et dossiers à copier
FILES_TO_COPY=()
for ITEM in * .[^.]*; do
  if [[ "$ITEM" != "node_modules" && "$ITEM" != ".git" && "$ITEM" != ".gitignore" && "$ITEM" != ".gitattributes" ]]; then
    FILES_TO_COPY+=("$ITEM")
  fi
done

TOTAL=${#FILES_TO_COPY[@]}
COUNT=0

# Fonction pour afficher la barre de progression
print_progress() {
  local progress=$(( ($COUNT * 100) / $TOTAL ))
  local bar_width=40
  local filled=$(( ($progress * $bar_width) / 100 ))
  local empty=$(( $bar_width - $filled ))
  printf "\r[%s%s] %d%% (%d/%d)" \
    "$(printf '#%.0s' $(seq 1 $filled))" \
    "$(printf ' %.0s' $(seq 1 $empty))" \
    "$progress" "$COUNT" "$TOTAL"
}

# 7️⃣ Copie avec barre de progression
for ITEM in "${FILES_TO_COPY[@]}"; do
  cp -r "$ITEM" "$DEST/" 2>/dev/null || true
  ((COUNT++))
  print_progress
done

echo -e "\n✅ Copie terminée. Livrable créé dans : $DEST"
