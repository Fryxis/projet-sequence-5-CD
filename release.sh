#!/bin/bash

set -e

# Choix de l'outil
TOOL=$1

if [ -z "$TOOL" ]; then
  echo "Quel outil souhaitez-vous utiliser ?"
  echo "1) standard-version"
  echo "2) semantic-release"
  read -p "Votre choix (1 ou 2) : " CHOICE
  case $CHOICE in
    1) TOOL="standard-version" ;;
    2) TOOL="semantic-release" ;;
    *) echo "Choix invalide" && exit 1 ;;
  esac
fi

# Configure Git si GH_PAT est disponible
if [ -n "$GH_PAT" ]; then
  echo "Configuration de Git avec GH_PAT..."
  git config --global user.name "github-actions[bot]"
  git config --global user.email "github-actions[bot]@users.noreply.github.com"

  # Remplacer l'URL remote par une URL authentifiée avec token
  git remote set-url origin "https://x-access-token:$GH_PAT@github.com/${GITHUB_REPOSITORY}.git"
fi

# Fonction release avec standard-version
release_with_standard_version() {
  echo "🔧 Incrémentation de version (standard-version)..."
  npx standard-version --release-as minor --changelog

  VERSION=$(jq -r '.version' package.json)
  echo "Nouvelle version : v$VERSION"

  echo "Push des tags et commits..."
  git push --follow-tags origin main

  echo "Création de la release GitHub..."
  gh release create "v$VERSION" -F CHANGELOG.md --title "Release v$VERSION"
}

# Fonction release avec semantic-release
release_with_semantic_release() {
  echo "Simulation de release avec semantic-release"
  npx semantic-release
}

# Lancer le bon outil
case $TOOL in
  standard-version)
    release_with_standard_version
    ;;
  semantic-release)
    release_with_semantic_release
    ;;
  *)
    echo "Outil non reconnu : $TOOL"
    exit 1
    ;;
esac
