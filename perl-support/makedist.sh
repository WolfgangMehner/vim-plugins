#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive perl-support.zip
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

archive_name="perl-support"

#-------------------------------------------------------------------------------
#   Hotkeys: PDF und LaTeX-Quelle kopieren
#-------------------------------------------------------------------------------
cp hotkeys.latex/perl-hot-keys.tex doc/
cp hotkeys.latex/perl-hot-keys.pdf doc/

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
 ./autoload/perlsupportprofiling.vim
 ./autoload/perlsupportregex.vim
 ./doc/perlsupport.txt
 ./doc/templatesupport.txt
 ./ftplugin/perl.vim
 ./ftplugin/pod.vim
 ./ftplugin/qf.vim
 ./perl-support/codesnippets/*
 ./perl-support/doc/*
 ./perl-support/modules/*
 ./perl-support/rc/*
 ./perl-support/README.perlsupport
 ./perl-support/scripts/*
 ./perl-support/templates/*
 ./perl-support/wordlists/*
 ./plugin/perl-support.vim
 ./syntax/template.vim
"

zip  $archive_name $filelist

