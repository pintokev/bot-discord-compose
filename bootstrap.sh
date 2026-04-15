#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DISCORD_REPO_URL="git@github.com:pintokev/Discord_Cogs.git"
GPT_REPO_URL="git@github.com:pintokev/response_gpt_gcp.git"
GEMINI_REPO_URL="git@github.com:pintokev/gemini_image.git"

DISCORD_DIR="${BASE_DIR}/discord"
GPT_DIR="${BASE_DIR}/GPT"
GEMINI_DIR="${BASE_DIR}/gemini"

clone_if_missing() {
  local repo_url="$1"
  local target_dir="$2"
  local repo_name="$3"

  if [ -d "${target_dir}/.git" ]; then
    echo "[OK] Repo ${repo_name} déjà présent dans ${target_dir}"
  else
    echo "[INFO] Clone de ${repo_name} dans ${target_dir}"
    git clone "${repo_url}" "${target_dir}"
  fi
}

check_file() {
  local file_path="$1"
  if [ ! -f "$file_path" ]; then
    echo "[ERREUR] Fichier manquant : $file_path"
    exit 1
  fi
}

echo "[INFO] Vérification des prérequis..."
command -v git >/dev/null 2>&1 || { echo "[ERREUR] git non installé"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "[ERREUR] docker non installé"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "[ERREUR] docker compose indisponible"; exit 1; }

echo "[INFO] Clonage des repos si nécessaire..."
clone_if_missing "${DISCORD_REPO_URL}" "${DISCORD_DIR}" "discord"
clone_if_missing "${GPT_REPO_URL}" "${GPT_DIR}" "gpt"
clone_if_missing "${GEMINI_REPO_URL}" "${GEMINI_DIR}" "gemini"

echo "[INFO] Vérification des fichiers nécessaires..."
check_file "${BASE_DIR}/docker-compose.yml"
check_file "${BASE_DIR}/.env"
check_file "${DISCORD_DIR}/Dockerfile"
check_file "${GPT_DIR}/Dockerfile"
check_file "${GEMINI_DIR}/Dockerfile"

echo "[INFO] Lancement de docker compose..."
cd "${BASE_DIR}"
docker compose up --build
