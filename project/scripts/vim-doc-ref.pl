#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  vim-doc-ref.pl
#
#        USAGE:  ./vim-doc-ref.pl vim-help-file
#
#  DESCRIPTION:  Check vim documentation file for unused hyper targets und 
#                undefined links.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), <mehner@fh-swf.de>
#      COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#      VERSION:  1.0
#      CREATED:  18.03.2006
#     REVISION:  28.10.2017
#===============================================================================

package	main;

use strict;
use warnings;

#---------------------------------------------------------------------------
#  command line parameter
#---------------------------------------------------------------------------
if ( $#ARGV < 0 )
{
  print "\n\tusage: $0 helpfile\n\n";
  exit 1;
}

my $INFILE_file_name  = $ARGV[0];               # input file nam


open  my $INFILE, '<', $INFILE_file_name
	or die  "$0 : failed to open  input file $INFILE_file_name : $!\n";

my	%target;
my	%otherTarget;
my	%ignoreTarget;

my	$rgx_target	= qr/\*([\w\d.-]+)\*/;
my	$rgx_link	= qr/\|([\w\d.-]+)\|/;

my $filecontent	= do{
	local  $/  = undef;                           # input record separator undefined
	<$INFILE>
};

close  $INFILE
	or warn "$0 : failed to close input file $INFILE_file_name : $!\n";

while ( $filecontent =~ m/$rgx_target/gxm ) {
	$target{$1}	= 0;                             # gather targets
}


while ( my $key = <DATA> ) {                    # links to ignore
	chomp	$key;
	$ignoreTarget{$key}	= 0;
}

while ( $filecontent =~ m/$rgx_link/gxm ) {
	if ( defined $target{$1} ) {
		$target{$1}++;                             # link for existing target
	}
	else {
		$otherTarget{$1}	= 0;                     # link for non-existing target
	}
}

print "\n input file : $0\n";
print "\n *****  unused targets  *****\n\n";

foreach my $key ( sort keys %target ) {
	if ( $target{$key} == 0 ) {
		print "\t$key\n";
	}
}

print "\n *****  undefined links  *****\n\n";
foreach my $key ( sort keys %otherTarget ) {
	if ( $otherTarget{$key} == 0 && ! exists $ignoreTarget{$key} ) {
		print "\t$key\n";
	}
}

print "\n *****  ignored links  *****\n\n";
foreach my $key ( sort keys %ignoreTarget ) {
	print "\t$key\n";
}
print "\n";


#---------------------------------------------------------------------------
#  links to ignore
#---------------------------------------------------------------------------
__DATA__
AUTHOR
AUTHORREF
CLASSNAME
COMPANY
COPYRIGHTHOLDER
CURSOR
DATE
EMAIL
FILENAME
PROJECT
TIME
YEAR
INTERPRETER
globpath
mapleader
maplocalleader
quickfix
quickfix.txt
regexp
runtimepath
terminal
word
WORD
List
Dictionary
