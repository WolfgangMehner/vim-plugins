#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive awk-support.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  2.0
#       CREATED:  17.08.2012 15:01:05 CEST
#===============================================================================

archive_name="awk-support"

#-------------------------------------------------------------------------------
#   Hotkeys: PDF und LaTeX-Quelle kopieren
#-------------------------------------------------------------------------------
cp hotkeys.latex/awk-hotkeys.tex doc/
cp hotkeys.latex/awk-hotkeys.pdf doc/

#-------------------------------------------------------------------------------
#   persönliche Angaben aus dem Haupt-Template-File ändern
#-------------------------------------------------------------------------------
MainTemplateFile=./templates/Templates

if [ -f $MainTemplateFile ] ; then
  sed --in-place  '/SetMacro.*AUTHOR/s/Dr. Fritz Mehner/YOUR NAME/'        $MainTemplateFile
  sed --in-place  '/SetMacro.*AUTHORREF/s/fgm//'                           $MainTemplateFile
  sed --in-place  '/SetMacro.*EMAIL/s/mehner.fritz@fh-swf.de//'            $MainTemplateFile
  sed --in-place  '/SetMacro.*ORGANIZATION/s/FH Südwestfalen, Iserlohn//'  $MainTemplateFile
else
  echo -e "Datei ${MainTemplateFile} nicht gefunden!\n"
fi

#-------------------------------------------------------------------------------
#   Archiv erstellen
#-------------------------------------------------------------------------------
cd ..

rm --force $archive_name'.zip'

filelist="
 ./autoload/mmtemplates/core.vim
 ./awk-support/codesnippets/*
 ./awk-support/doc/*
 ./awk-support/rc/*
 ./awk-support/README.awksupport
 ./awk-support/scripts/*
 ./awk-support/templates/*
 ./awk-support/wordlists/*
 ./doc/awksupport.txt
 ./doc/templatesupport.txt
 ./plugin/awk-support.vim
 ./syntax/template.vim
"

zip  $archive_name $filelist

