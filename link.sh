#!/usr/bin/env bash
set -euo pipefail

# link.sh — symlink dotfiles from a JSON map, backing up existing files first.
# Usage:
#   ./link.sh path/to/dotfiles.json [--backup-dir ~/dotfile_backups/2025-09-15_00-00-00] [--relative] [--dry-run]
#
# JSON format:
# {
#   "alacritty/alacritty.toml": "~/.config/alacritty/alacritty.toml",
#   "zsh/.zshrc": "~/.zshrc"
# }

# -------- args & defaults --------
JSON_FILE="${1:-}"
shift || true

if [[ -z "${JSON_FILE}" || ! -f "${JSON_FILE}" ]]; then
  echo "Usage: $0 path/to/dotfiles.json [--backup-dir DIR] [--relative] [--dry-run]" >&2
  exit 1
fi

BACKUP_DIR=""
RELATIVE_LINKS=false
DRY_RUN=false

while (( "$#" )); do
  case "$1" in
    --backup-dir)
      BACKUP_DIR="${2:-}"; shift 2 ;;
    --relative)
      RELATIVE_LINKS=true; shift ;;
    --dry-run)
      DRY_RUN=true; shift ;;
    *)
      echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

timestamp() { date +"%Y-%m-%d_%H-%M-%S"; }

# Default backup dir if not provided
if [[ -z "$BACKUP_DIR" ]]; then
  BACKUP_DIR="$HOME/.dotfile_backups/$(timestamp)"
fi

# Where your repo is (assumes you run from repo root)
REPO_ROOT="$(pwd)"

# -------- helpers --------
expand_tilde() {
  # expand leading ~ to $HOME
  local p="$1"
  echo "${p/#\~/$HOME}"
}

backup_existing() {
  local dst="$1"
  local backup_path="$BACKUP_DIR/${dst#/}"   # mirror absolute path under backup dir

  # Skip if destination is a symlink
  if [[ -L "$dst" ]]; then
    echo "• Skip backup: $dst is a symlink"
    return
  fi

  echo "• Backup: $dst → $backup_path"
  if [[ "$DRY_RUN" == true ]]; then
    return
  fi

  mkdir -p "$(dirname "$backup_path")"
  # Use mv to keep original attributes; works for files and directories
  mv -T "$dst" "$backup_path"
}

link_target_for() {
  local src_abs="$1"
  local dst="$2"
  local target="$src_abs"

  if [[ "$RELATIVE_LINKS" == true ]] && command -v realpath >/dev/null 2>&1; then
    target="$(realpath --relative-to "$(dirname "$dst")" "$src_abs")"
  fi

  echo "$target"
}

ensure_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed. Install with: sudo pacman -S jq" >&2
    exit 1
  fi
}

# -------- main --------
ensure_jq
echo "Backup directory: $BACKUP_DIR"
[[ "$RELATIVE_LINKS" == true ]] && echo "Symlinks: relative" || echo "Symlinks: absolute"
[[ "$DRY_RUN" == true ]] && echo "Mode: DRY RUN (no changes will be made)"

# Read "key → value" pairs as TSV to avoid word-splitting issues
while IFS=$'\t' read -r src_key dst_val; do
  # Expand tilde in destination
  dst_abs="$(expand_tilde "$dst_val")"
  src_abs="$REPO_ROOT/$src_key"

  if [[ ! -e "$src_abs" ]]; then
    echo "⚠️  Source does not exist: $src_abs — skipping"
    continue
  fi

  # Create parent dir
  if [[ "$DRY_RUN" == true ]]; then
    echo "• mkdir -p $(dirname "$dst_abs")"
  else
    mkdir -p "$(dirname "$dst_abs")"
  fi

  # If destination exists (file or dir, but not symlink), back it up
  if [[ -e "$dst_abs" && ! -L "$dst_abs" ]]; then
    backup_existing "$dst_abs"
  fi

  # If destination is a symlink, check if it points to the correct source
  if [[ -L "$dst_abs" ]]; then
    link_target="$(link_target_for "$src_abs" "$dst_abs")"
    current_target="$(readlink "$dst_abs")"
    if [[ "$current_target" == "$link_target" ]]; then
      echo "• Skip: $dst_abs already links to $link_target"
      continue
    else
      echo "• Remove existing symlink: $dst_abs"
      if [[ "$DRY_RUN" != true ]]; then
        rm "$dst_abs"
      fi
    fi
  fi

  # Create the symlink
  link_target="$(link_target_for "$src_abs" "$dst_abs")"
  echo "• Link: $dst_abs → $link_target"
  if [[ "$DRY_RUN" == true ]]; then
    continue
  fi

  ln -s "$link_target" "$dst_abs"

done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$JSON_FILE")

echo "✅ Done."
echo "Backups (if any) saved under: $BACKUP_DIR"