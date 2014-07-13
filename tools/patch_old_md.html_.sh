#!/bin/bash
function shw_grey { echo -e '\033[1;30m'"$1"'\033[0m'; }
function shw_norm { echo    "$1"; }
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function shw_warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function shw_err  { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

function show_usage {
  cat <<EOT
$0 v0.1
This program will check and patch .md.html files that have non-working-javascript-links to use the new-and-working-javascript-links

Usage: $0 <YOURFILE.md.html>
EOT
}

function test_if_file_is_already_patched {
 # Usage: test_if_file_is_already_patched "myfile.md.html"
 #
 # Returns:
 #      0             - if file is already patched
 #      255           - if file is not patched

 local THEFILE=$1
 if grep 'https://rawgit.com/jgallen23/toc/master/dist/toc.min.js' $THEFILE &>/dev/null; then
   # file is already patched
   return 0
 else
   # file is not patched
   return 255
 fi

}

function patch_file {
  # Usage: $0 "myunpatchedfile.md.html"
  # 
  # Returns:
  #   0   if file was garanteedly patched
  #   1   if file could not be patched because of some error
  local THEFILE=$1
  test_if_file_is_already_patched $THEFILE && return 0 
  sed --in-place 's@https://raw.github.com/jgallen23/toc/master/dist/jquery.toc.min.js@https://rawgit.com/jgallen23/toc/master/dist/toc.min.js@g; s@https://github.com/zipizap/strapdown_template/raw/master/js/init_TOC.js@https://rawgit.com/zipizap/strapdown_template/master/js/init_TOC.js@g' $THEFILE &>/dev/null
  test_if_file_is_already_patched $THEFILE || { shw_err "Failed to patch file '$THEFILE'"; return 1; }
  return 0
}

[[ $@ ]] || { show_usage; exit 255; }
shw_info "Patching files..."
for THEMDHTML_FILE in "$@"; do
  [[ -r $THEMDHTML_FILE ]] || { shw_err "Could not read file '$THEMDHTML_FILE'"; continue; }
  if test_if_file_is_already_patched $THEMDHTML_FILE; then
    # file is already patched
    # ...do nothing! skip silently...
    shw_norm "=== already patched    '$THEMDHTML_FILE'"
  else
    # file is still unpatched
    shw_norm "*** patching           '$THEMDHTML_FILE'"
    patch_file $THEMDHTML_FILE
  fi
  diff $THEMDHTML_FILE <(sed 's@https://raw.github.com/jgallen23/toc/master/dist/jquery.toc.min.js@https://rawgit.com/jgallen23/toc/master/dist/toc.min.js@g; s@https://github.com/zipizap/strapdown_template/raw/master/js/init_TOC.js@https://rawgit.com/zipizap/strapdown_template/master/js/init_TOC.js@g' $THEMDHTML_FILE)
done
