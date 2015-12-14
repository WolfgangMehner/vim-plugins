#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive cvim.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@web.de
#       VERSION:  2.0
#       CREATED:  04.01.2013 13:35:48 CEST
#===============================================================================

plugin='c-support'

filelist="
 ./${plugin}/README.csupport
 ./${plugin}/codesnippets/*
 ./${plugin}/doc/ChangeLog
 ./${plugin}/doc/c-hotkeys.pdf
 ./${plugin}/doc/c-hotkeys.tex
 ./${plugin}/rc/*
 ./${plugin}/scripts/*
 ./${plugin}/templates/*.template
 ./${plugin}/templates/Templates
 ./${plugin}/wordlists/*
 ./autoload/mmtemplates/core.vim
 ./autoload/mmtoolbox/cmake.vim
 ./autoload/mmtoolbox/doxygen.vim
 ./autoload/mmtoolbox/make.vim
 ./autoload/mmtoolbox/tools.vim
 ./doc/csupport.txt
 ./doc/templatesupport.txt
 ./doc/toolbox.txt
 ./doc/toolboxcmake.txt
 ./doc/toolboxdoxygen.txt
 ./doc/toolboxmake.txt
 ./ftplugin/c.vim
 ./ftplugin/make.vim
 ./plugin/c.vim
 ./syntax/template.vim
"
#-------------------------------------------------------------------------------
#   build archive, remove old one, restore personalized version
#-------------------------------------------------------------------------------

cd ..

rm --force cvim.zip

zip -r cvim.zip ${filelist}

cd -

