#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  filter-vimtags.pl
#
#        USAGE:  filter-vimtags.pl [-i input file] [-o output file]
#
#  DESCRIPTION:  more remove stars from vim-doc labels, such as:
#                  *csupport-run*
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Fritz Mehner (fgm), mehner@web.de
#      VERSION:  1.0
#      CREATED:  20.03.2009
#     REVISION:  15.11.2014
#===============================================================================

use strict;
use warnings;
use Getopt::Std;                                # Process single-character switches

our($opt_i, $opt_o);                            # declare package variables

getopts('i:o:');                                # 

$opt_i	= '-' unless defined $opt_i;            # if not set, set output to STDIN
$opt_o	= '-' unless defined $opt_o;            # if not set, set output to STDOUT

open  STDIN, "< $opt_i"
	or die  "$0 : failed to open   input file '$opt_i' : $!\n";

my	$rgx_vimtag	= q/<b class="vimtag">\*/;
my	$line;
my	@lines	= <STDIN>;

close STDIN 
	or warn "$0 : failed to close  input file '$opt_i' : $!\n";

open  STDOUT, "+> $opt_o"
	or die  "$0 : failed to open  output file '$opt_o' : $!\n";

foreach my $line ( @lines ) {
	if (  $line =~ m/$rgx_vimtag/ ) {
		$line =~ s/(class="vimtag">)\*/$1/g;
		$line =~ s#</a>\*</b>#</a></b>#g;
	}
	print $line;
}

close STDOUT 
	or warn "$0 : failed to close output file '$opt_o' : $!\n";

