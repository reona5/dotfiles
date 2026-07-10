#!/usr/bin/env bash
set -ue

source $(dirname "${BASH_SOURCE[0]:-$0}")/utilfuncs.sh

#--------------------------------------------------------------#
##          Functions                                         ##
#--------------------------------------------------------------#

function link_to_homedir() {
  print_notice "backup old dotfiles..."
  local tmp_date
  tmp_date=$(date '+%y%m%d-%H%M%S')
  local backupdir="${XDG_CACHE_HOME:-$HOME/.cache}/dotbackup/$tmp_date"
  mkdir_not_exist "$backupdir"
  print_info "create backup directory: $backupdir\n"

  print_info "Creating symlinks"
  local current_dir
  current_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
  local dotfiles_dir
  dotfiles_dir="$(builtin cd "$current_dir" && git rev-parse --show-toplevel)"
  if [[ "$HOME" != "$dotfiles_dir" ]]; then
    for f in "$dotfiles_dir"/.??*; do
      local f_filename
      f_filename=$(basename "$f")
      [[ "$f_filename" == ".git" || \
      "$f_filename" == ".github" || \
      "$f_filename" == ".DS_Store" ]] && continue
      backup_and_link "$f" "$HOME" "$backupdir"
    done
    link_codex_config "$dotfiles_dir/.config/codex" "${CODEX_HOME:-$HOME/.codex}" "$backupdir"
    link_claude_config "$dotfiles_dir/.config/claude" "$HOME/.claude" "$backupdir"
    backup_and_link_path "$dotfiles_dir/.config/zsh" "$HOME/.zsh" "$backupdir"
  fi
}

function link_codex_config() {
  local source_dir=$1
  local codex_home=$2
  local backupdir=$3
  local filename

  [[ "$source_dir" == "$codex_home" ]] && return
  mkdir_not_exist "$codex_home"
  for filename in config.toml hooks.json; do
    [[ -f "$source_dir/$filename" ]] || continue
    backup_and_link "$source_dir/$filename" "$codex_home" "$backupdir"
  done
}

function link_claude_config() {
  local source_dir=$1
  local claude_home=$2
  local backupdir=$3
  local filename

  if [[ -L "$claude_home" && ! -e "$claude_home" ]]; then
    command rm -f "$claude_home"
  fi
  mkdir_not_exist "$claude_home"
  for filename in settings.json skills statusline.py hooks; do
    [[ -e "$source_dir/$filename" ]] || continue
    backup_and_link "$source_dir/$filename" "$claude_home" "$backupdir"
  done
}

function backup_and_link_path() {
  local link_src_file=$1
  local link_dest_file=$2
  local backupdir=$3

  if [[ -L "$link_dest_file" ]]; then
    command rm -f "$link_dest_file"
  elif [[ -e "$link_dest_file" ]]; then
    command mv "$link_dest_file" "$backupdir"
  fi
  print_default "Creating symlink for $link_src_file -> $link_dest_file"
  command ln -snf "$link_src_file" "$link_dest_file"
}

function backup_and_link() {
  local link_src_file=$1
  local link_dest_dir=$2
  local backupdir=$3
  local f_filename
  f_filename=$(basename "$link_src_file")
  local f_filepath="$link_dest_dir/$f_filename"
  if [[ -L "$f_filepath" ]]; then
    command rm -f "$f_filepath"
  fi

  if install_by_local_installer "$link_src_file" "$backupdir"; then
    return
  fi

  if [[ -e "$f_filepath" && ! -L "$f_filepath" ]]; then
    command mv "$f_filepath" "$backupdir"
  fi
  print_default "Creating symlink for $link_src_file -> $link_dest_dir"
  command ln -snf "$link_src_file" "$link_dest_dir"
}

function install_by_local_installer() {
  local link_src_file=$1
  local backupdir=$2

  local file_list
  file_list=$(command find "$link_src_file" -name "_install.sh" -type f 2>/dev/null)
  if [[ -n "$file_list" ]]; then
    if [[ -e "$f_filepath" ]]; then
      command cp -r "$f_filepath" "$backupdir"
    fi
    for f in $file_list; do
      eval "$f"
    done
    return 0
  fi
  return 1
}

function helpmsg() {
  command printf "Usage: $0 [--help | -h]" 0>&2
  command printf ""
}

#--------------------------------------------------------------#
##          Main                                              ##
#--------------------------------------------------------------#

IS_INSTALL="true"

while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    install)
      IS_INSTALL="true"
      ;;
    *)
      ;;
  esac
  shift
done

if [[ "$IS_INSTALL" = true ]];then
  link_to_homedir
    print_info ""
    print_info "#####################################################"
    print_info "$(basename "${BASH_SOURCE[0]:-$0}") update finish!!!"
    print_info "#####################################################"
    print_info ""
fi
