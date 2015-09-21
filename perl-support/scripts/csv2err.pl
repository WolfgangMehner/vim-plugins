#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  csv2err.pl
#
#        USAGE:  ./csv2err.pl [-hH] -i CSV-file -n source-file [ -o outfile ][ -s criterion ]
#
#  DESCRIPTION:  Generate a Vim-quickfix compatible errorfile from a CSV-file 
#                produced by Devel::NYTProf.
#                Specify CSV-file with full path.
#                Specify source-file with full path.
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Fritz Mehner (fgm), mehner@web.de
#      VERSION:  2.0
#      CREATED:  13.02.2009 17:04:00
#===============================================================================

use strict;
use warnings;

use Getopt::Std;
use File::Basename;

our( $opt_H, $opt_h, $opt_i, $opt_o, $opt_s, $opt_n );
getopts('hHi:o:s:n:');                            # process command line arguments

#-------------------------------------------------------------------------------
#  check for parameters
#-------------------------------------------------------------------------------
if ( defined $opt_h || !defined $opt_i ) {      # process option -h
	usage();
}

my	$criterion		= 'file line time calls time_per_call';
my	$sortcriterion	= 'none';

if ( defined $opt_s ) {
	$sortcriterion	= $opt_s;
	usage() until $criterion =~ m/\b$opt_s\b/;
}

my  $csv_file_name = $opt_i;                    # input file name

#-------------------------------------------------------------------------------
#  output file
#-------------------------------------------------------------------------------

if ( defined $opt_o ) {
	open  FILE,  "> $opt_o" or do {
		warn "Couldn't open $opt_o: $!.  Using STDOUT instead.\n";
		undef $opt_o;
	};
}

my $handle = ( defined $opt_o ? \*FILE : \*STDOUT );

if ( defined $opt_o ) {
	close  FILE
		or warn "$0 : failed to close output file '$opt_o' : $!\n";
	unlink $opt_o;
}

#-------------------------------------------------------------------------------
#  prepare file names
#  The quickfix format needs the absolute file name of the source file.
#  This file name is constructed from the mame of the csv-file, e.g.
#    PATH/nytprof/test-pl-line.csv
#  gives
#    PATH/test.pl
#  The name of the output file is also constructed:
#    PATH/nytprof/test.pl.err
#-------------------------------------------------------------------------------
my  $src_filename	= $opt_n;

#-------------------------------------------------------------------------------
#  read the CSV-file
#-------------------------------------------------------------------------------
open  my $csv, '<', $csv_file_name
  or die  "$0 : failed to open  input file '$csv_file_name' : $!\n";

my  $line;
foreach my $i ( 1..3 ) {                        # read the header
	$line = <$csv>;
	print $line;
}
$line = <$csv>;                                 # skip NYTProf format line

print "#\n# sort criterion:  $sortcriterion\n";
print    "#         FORMAT:  filename : line number : time : calls : time/call : code\n#\n";

my  @rawline= <$csv>;                           # rest of the CSV-file
chomp @rawline;

close  $csv
  or warn "$0 : failed to close input file '$csv_file_name' : $!\n";

#---------------------------------------------------------------------------
# filter lines
#  input format: <time>,<calls>,<time/call>,<source line> 
# output format: <filename>:<line>:<time>:<calls>:<time/call>: <source line>
#---------------------------------------------------------------------------
my  $sourcelinenumber 	= 0;
my  $sourceline;
my  $cookedline;
my  @linepart;
my  @line;
my	$delim	= ':';


foreach my $n ( 0..$#rawline ) {
	$sourcelinenumber++;
	@linepart    = split ( /,/, $rawline[$n] );
	$sourceline	 = join( ',', @linepart[3..$#linepart] );
	$cookedline  = $src_filename.$delim.$sourcelinenumber.$delim;
	$cookedline .= join( $delim, @linepart[0..2] ).$delim.' ';
	$cookedline .= $sourceline;
	unless ( defined $opt_H && ( $linepart[0]+$linepart[1]+$linepart[2] == 0 ) ) {
		push @line, $cookedline;
	}
}

#-------------------------------------------------------------------------------
#  sort file names (field index 0)
#-------------------------------------------------------------------------------
if ( $sortcriterion eq 'file' ) {
	@line	= sort {
		my $ind	= ( $a !~ m/^[[:alpha:]]$delim/ ) ? 0 : 1;
		my @a	= split /$delim/, $a;
		my @b	= split /$delim/, $b;
        $a[$ind] cmp $b[$ind];                  # ascending
	} @line;
}

#-------------------------------------------------------------------------------
#  sort line numbers (field index 1)
#-------------------------------------------------------------------------------
if ( $sortcriterion eq 'line' ) {
	@line	= sort {
		my $ind	= ( $a !~ m/^[[:alpha:]]$delim/ ) ? 1 : 2;
		my @a	= split /$delim/, $a;
		my @b	= split /$delim/, $b;
        $a[$ind] <=> $b[$ind];                  # ascending
	} @line;
}

#-------------------------------------------------------------------------------
#  sort time (index 2)
#-------------------------------------------------------------------------------
if ( $sortcriterion eq 'time'  ) {
	@line	= sort {
		my $ind	= ( $a !~ m/^[[:alpha:]]$delim/ ) ? 2 : 3;
		my @a	= split /$delim/, $a;
		my @b	= split /$delim/, $b;
        $b[$ind] <=> $a[$ind];                  # descending
	} @line;
}

#-------------------------------------------------------------------------------
#  sort calls (index 3)
#-------------------------------------------------------------------------------
if ( $sortcriterion eq 'calls'  ) {
	@line	= sort {
		my $ind	= ( $a !~ m/^[[:alpha:]]$delim/ ) ? 3 : 4;
		my @a	= split /$delim/, $a;
		my @b	= split /$delim/, $b;
        $b[$ind] <=> $a[$ind];                  # descending
	} @line;
}

#-------------------------------------------------------------------------------
#  sort time_per_call (index 4)
#-------------------------------------------------------------------------------
if ( $sortcriterion eq 'time_per_call'  ) {
	@line	= sort {
		my $ind	= ( $a !~ m/^[[:alpha:]]$delim/ ) ? 4 : 5;
		my @a	= split /$delim/, $a;
		my @b	= split /$delim/, $b;
        $b[$ind] <=> $a[$ind];                  # descending
	} @line;
}

#-------------------------------------------------------------------------------
#  write result
#-------------------------------------------------------------------------------
foreach my $line ( @line ) {
	print $line, "\n";
}

#-------------------------------------------------------------------------------
#  subroutine usage()
#-------------------------------------------------------------------------------
sub usage {
print <<EOF;
usage: $0 [-hH] -i CSV-file -n source-file  [ -o outfile ][ -s criterion ]
  -h       this message
  -H       hot spots only ( time, calls, and time/call are zero)
  -i       input file (CSV)
  -n       source file (*.pl or *.pm)
  -s       sort criterion (file, line,  time, calls, time_per_call)
EOF
exit 0;
}	# ----------  end of subroutine usage  ----------
