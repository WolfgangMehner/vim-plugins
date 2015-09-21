#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive vim-support.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@web.de
#       VERSION:  2.0
#       CREATED:  11.08.2013 19:22:37 CEST
#===============================================================================

plugin='vim-support'

filelist="
 ./autoload/mmtemplates/*
 ./doc/vimsupport.txt
 ./doc/templatesupport.txt
 ./${plugin}/codesnippets/*
 ./${plugin}/doc/vim-hotkeys.pdf
 ./${plugin}/doc/vim-hotkeys.tex
 ./${plugin}/doc/ChangeLog
 ./${plugin}/rc/*
 ./${plugin}/README.vimsupport
 ./${plugin}/scripts/*
 ./${plugin}/templates/*.templates
 ./${plugin}/templates/Templates
 ./plugin/vim-support.vim
 ./syntax/template.vim
"
#-------------------------------------------------------------------------------
#   build archive, remove old one, restore personalized version
#-------------------------------------------------------------------------------

cd ..

rm --force "${plugin}.zip"

zip -r "${plugin}" ${filelist}

cd -

