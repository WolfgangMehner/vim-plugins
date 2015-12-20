#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive latex-support.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@web.de
#       VERSION:  2.0
#       CREATED:  04.01.2013 13:35:48 CEST
#===============================================================================

archive_name='latex-support'

filelist="
 ./autoload/mmtemplates/core.vim
 ./autoload/mmtoolbox/make.vim
 ./autoload/mmtoolbox/tools.vim
 ./doc/latexsupport.txt
 ./doc/templatesupport.txt
 ./doc/toolbox.txt
 ./doc/toolboxmake.txt
 ./latex-support/README.latexsupport
 ./latex-support/codesnippets/*
 ./latex-support/doc/ChangeLog
 ./latex-support/doc/latex-hotkeys.pdf
 ./latex-support/doc/latex-hotkeys.tex
 ./latex-support/rc/*
 ./latex-support/templates/*
 ./latex-support/wordlists/*
 ./ftplugin/make.vim
 ./ftplugin/tex.vim
 ./plugin/latex-support.vim
 ./syntax/template.vim
"
#-------------------------------------------------------------------------------
#   build archive, remove old one, restore personalized version
#-------------------------------------------------------------------------------

cd ..

rm --force "${archive_name}.zip"

zip -r "${archive_name}" ${filelist}

cd -

