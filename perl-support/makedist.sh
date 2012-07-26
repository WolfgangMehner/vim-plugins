#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
# 
#         USAGE:  ./makedist.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  1.0
#       CREATED:  12.05.2007 08:41:41 CEST
#===============================================================================

archive_name="perl-support"
exclude_list="makedist.sh hotkeys.latex/\* *.swp *.cvsignore"

rm --force $archive_name".zip"

#-------------------------------------------------------------------------------
#   Hotkeys: PDF und LaTeX-Quelle kopieren
#-------------------------------------------------------------------------------
cp hotkeys.latex/perl-hot-keys.tex perl-support/doc/
cp hotkeys.latex/perl-hot-keys.pdf perl-support/doc/

#-------------------------------------------------------------------------------
#   persönliche Angaben aus dem Haupt-Template-File ändern
#-------------------------------------------------------------------------------
templatefile=./perl-support/templates/Templates

if [ -f $templatefile ] ; then
	sed --in-place  '/SetMacro.*AUTHOR/s/Dr. Fritz Mehner/YOUR NAME/'        $templatefile
	sed --in-place  '/SetMacro.*AUTHORREF/s/fgm//'                           $templatefile
	sed --in-place  '/SetMacro.*EMAIL/s/mehner.fritz@fh-swf.de//'            $templatefile
	sed --in-place  '/SetMacro.*ORGANIZATION/s/FH Südwestfalen, Iserlohn//'  $templatefile
else
	echo -e "Datei ${templatefile} nicht gefunden!\n"
fi

#-------------------------------------------------------------------------------
#   Archiv erstellen
#-------------------------------------------------------------------------------
eval zip -r $archive_name . -x $exclude_list

