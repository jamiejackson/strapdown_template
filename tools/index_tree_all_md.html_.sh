#!/bin/bash
function shw_grey { echo -e '\033[1;30m'"$1"'\033[0m'; }
function shw_norm { echo    "$1"; }
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function shw_warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function shw_err  { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

# Design
#  
#  Show description and validate user-confirmation
#  Download https://github.com/zipizap/strapdown_template/raw/master/strapdown_template.md.html into $TMPDIR/TEMPLATE.md.html
#  Create $TMPDIR/index_tree.md.html, containing from top to buttom:
#     . cat $TMPDIR/TEMPLATE.md.html | sed -n '1,/^<xmp /p' | sed 's/<title>.*<\/title>/<title>Index Tree<\/title>/g'
#     . # Files .md.html
#     . find all *.md.html files in subdirs, and for each of them write a line with relative path, like
#           [./dir1/dir2/thefile.md.html](./dir1/dir2/thefile.md.html)  
#     . # Files .mm
#     . find all *.mm files in subdirs, and for each of them write a line with relative path, like
#           [./dir1/dir2/thefile.mm](./dir1/dir2/thefile.mm)  
#     . cat $TMPDIR/TEMPLATE.md.html | sed -n '/^<\/xmp>/,$p'
#  Move -f $TMPDIR/index_tree.md.html --> ./index_tree.md.html



function handler_exit {
  [[ "$TMPDIR" ]] && rm -rf $TMPDIR &>/dev/null
}

# Implementation
#  
#  Show description and validate user-confirmation
cat <<EOT
  $0 v1.0

  It will generate a ./index_tree.md.html file, containing links to all the *.md.html and *.mm files 
  existing in subdirectories (recursive) 
  
  Please press Enter to continue or CTRL-C to abort
EOT
read
#  Download https://github.com/zipizap/strapdown_template/raw/master/strapdown_template.md.html into $TMPDIR/TEMPLATE.md.html
shw_info "Building index tree... wait..."
TMPDIR=$(mktemp -d)
trap handler_exit EXIT
wget https://github.com/zipizap/strapdown_template/raw/master/strapdown_template.md.html -O $TMPDIR/TEMPLATE.md.html -q
#  Create $TMPDIR/index_tree.md.html, containing from top to buttom:
#     . cat $TMPDIR/TEMPLATE.md.html | sed -n '1,/^<xmp /p | sed 's/<title>.*<\/title>/<title>Index Tree<\/title>/g' 
cat $TMPDIR/TEMPLATE.md.html | sed -n '1,/^<xmp /p' | sed 's/<title>.*<\/title>/<title>Index Tree<\/title>/g' > $TMPDIR/index_tree.md.html
#     . # Files .md.html
echo "# Files .md.html" | tee -a $TMPDIR/index_tree.md.html
#     . find all *.md.html files in subdirs, and for each of them write a line with relative path, like
#           [./dir1/dir2/thefile.md.html](./dir1/dir2/thefile.md.html)
find . -type f -iname '*.md.html' | sort | \
  while read FILE_REL_PATH; do
  cat <<EOT | tee -a $TMPDIR/index_tree.md.html
   [$FILE_REL_PATH]($FILE_REL_PATH)  
EOT
  done
#     . # Files .mm
echo "# Files .mm" | tee -a $TMPDIR/index_tree.md.html
#     . find all *.mm files in subdirs, and for each of them write a line with relative path, like
find . -type f -iname '*.mm' | sort | \
  while read FILE_REL_PATH; do
  cat <<EOT | tee -a $TMPDIR/index_tree.md.html
   [$FILE_REL_PATH]($FILE_REL_PATH)  
EOT
  done
#     . cat $TMPDIR/TEMPLATE.md.html | sed -n '/^<\/xmp>/,$p'
cat $TMPDIR/TEMPLATE.md.html | sed -n '/^<\/xmp>/,$p'>> $TMPDIR/index_tree.md.html
#  Move -f $TMPDIR/index_tree.md.html --> ./index_tree.md.html
mv -f $TMPDIR/index_tree.md.html ./index_tree.md.html
shw_info "Index complete - see $PWD/index_tree.md.html [file://$PWD/index_tree.md.html]"
exit 0
