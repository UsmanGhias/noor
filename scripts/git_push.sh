#!/usr/bin/env bash
# Push current repo to origin. Works for public and private GitHub repos.
set -euo pipefail

branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No origin remote. Add one, e.g.:"
  echo "  git remote add origin git@github.com:UsmanGhias/REPO.git"
  exit 1
fi

git push -u origin "$branch"
echo "Pushed $branch to $(git remote get-url origin)"
