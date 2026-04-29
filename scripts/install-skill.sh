#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/install-skill.sh [target-project] [options]

Options:
  -s, --skill NAME       Skill name to install. Can be repeated.
                         Defaults to all top-level skill directories.
  -t, --tools LIST       Comma-separated tools: codex,claudecode,opencode,all.
                         Defaults to all.
  -f, --force            Replace an existing symlink that points elsewhere.
                         Existing real directories/files are never replaced.
  -h, --help             Show this help.

Examples:
  scripts/install-skill.sh /path/to/project
  scripts/install-skill.sh /path/to/project --skill commit-messages
  scripts/install-skill.sh . --tools codex,opencode
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

target_project="."
tools="all"
force="false"
skills=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--skill)
      [[ $# -ge 2 ]] || die "--skill requires a value"
      skills+=("$2")
      shift 2
      ;;
    -t|--tools)
      [[ $# -ge 2 ]] || die "--tools requires a value"
      tools="$2"
      shift 2
      ;;
    -f|--force)
      force="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      target_project="$1"
      shift
      ;;
  esac
done

[[ -d "$target_project" ]] || die "target project does not exist: $target_project"
target_project="$(cd -- "$target_project" && pwd)"

if [[ ${#skills[@]} -eq 0 ]]; then
  for skill_md in "$repo_root"/*/SKILL.md; do
    [[ -f "$skill_md" ]] || continue
    skills+=("$(basename -- "$(dirname -- "$skill_md")")")
  done
fi

[[ ${#skills[@]} -gt 0 ]] || die "no skills found in $repo_root"

expanded_tools=()
IFS=',' read -ra requested_tools <<< "$tools"
for tool in "${requested_tools[@]}"; do
  case "$tool" in
    all)
      expanded_tools+=(codex claudecode opencode)
      ;;
    codex|claudecode|claude|claude-code|opencode)
      expanded_tools+=("$tool")
      ;;
    "")
      ;;
    *)
      die "unsupported tool: $tool"
      ;;
  esac
done

[[ ${#expanded_tools[@]} -gt 0 ]] || die "no tools selected"

install_dir_for_tool() {
  case "$1" in
    codex)
      printf '.codex/skills\n'
      ;;
    claudecode|claude|claude-code)
      printf '.claude/skills\n'
      ;;
    opencode)
      printf '.opencode/skills\n'
      ;;
    *)
      return 1
      ;;
  esac
}

same_target() {
  local link_path="$1"
  local source_path="$2"

  [[ -L "$link_path" ]] || return 1
  [[ -e "$link_path/SKILL.md" ]] || return 1

  local link_real source_real
  link_real="$(cd -- "$link_path" && pwd -P)"
  source_real="$(cd -- "$source_path" && pwd -P)"
  [[ "$link_real" == "$source_real" ]]
}

install_skill() {
  local skill="$1"
  local tool="$2"
  local source_path="$repo_root/$skill"
  local install_dir relative_install_dir link_path

  [[ -f "$source_path/SKILL.md" ]] || die "skill not found: $skill"

  relative_install_dir="$(install_dir_for_tool "$tool")"
  install_dir="$target_project/$relative_install_dir"
  link_path="$install_dir/$skill"

  mkdir -p "$install_dir"

  if same_target "$link_path" "$source_path"; then
    printf 'ok: %s already installed for %s\n' "$skill" "$tool"
    return
  fi

  if [[ -L "$link_path" ]]; then
    if [[ "$force" == "true" ]]; then
      rm "$link_path"
    else
      die "$link_path already exists and points elsewhere. Re-run with --force to replace the symlink."
    fi
  elif [[ -e "$link_path" ]]; then
    die "$link_path already exists and is not a symlink. Remove or rename it manually first."
  fi

  ln -s "$source_path" "$link_path"
  printf 'installed: %s -> %s\n' "$link_path" "$source_path"
}

for skill in "${skills[@]}"; do
  for tool in "${expanded_tools[@]}"; do
    install_skill "$skill" "$tool"
  done
done
