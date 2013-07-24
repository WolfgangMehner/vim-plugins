#!/bin/bash - 
#===============================================================================
#
#          FILE: makedist.sh
# 
#         USAGE: ./makedist.sh 
# 
#   DESCRIPTION:  create archive bash-support.zip
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
#  ORGANIZATION: FH Südwestfalen, Iserlohn, Germany
#       CREATED:  20.05.2013 20:33:12 CEST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

archive_name="bash-support"

#-------------------------------------------------------------------------------
#   Hotkeys: PDF und LaTeX-Quelle kopieren
#-------------------------------------------------------------------------------
cp hotkeys.latex/bash-hotkeys.tex doc/
cp hotkeys.latex/bash-hotkeys.pdf doc/

#-------------------------------------------------------------------------------
#   persönliche Angaben aus dem Haupt-Template-File ändern
#-------------------------------------------------------------------------------
MainTemplateFile=templates/Templates

if [ -f $MainTemplateFile ] ; then
	cp $MainTemplateFile $MainTemplateFile.save
  sed --in-place '/SetMacro.*AUTHOR/s/Dr. Fritz Mehner/YOUR NAME/'                $MainTemplateFile
  sed --in-place '/SetMacro.*AUTHORREF/s/fgm//'                                   $MainTemplateFile
  sed --in-place '/SetMacro.*EMAIL/s/mehner.fritz@fh-swf.de//'                    $MainTemplateFile
  sed --in-place '/SetMacro.*ORGANIZATION/s/FH Südwestfalen, Iserlohn, Germany//' $MainTemplateFile
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
 ./bash-support/codesnippets/*
 ./bash-support/doc/*
 ./bash-support/rc/*
 ./bash-support/README.bashsupport
 ./bash-support/scripts/*
 ./bash-support/templates/*.templates
 ./bash-support/templates/Templates
 ./bash-support/wordlists/*
 ./doc/bashsupport.txt
 ./doc/templatesupport.txt
 ./plugin/bash-support.vim
 ./syntax/template.vim
"

 zip -r $archive_name $filelist

mv bash-support/$MainTemplateFile.save bash-support/$MainTemplateFile

