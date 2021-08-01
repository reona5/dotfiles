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
  fi
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

