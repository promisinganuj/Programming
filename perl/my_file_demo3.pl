use strict;
use warnings;

open FILE, "my_file_demo1.pl" or die $!;

if ($ARGV[0] == 1) {
	my @last5;
	while (<FILE>){
		push @last5, $_;
		shift @last5 if @last5 > 5 # Take from the beginning
	}
	print "Last file lines:\n", @last5;
}
else{
	my @my_file = <FILE>;
	print "Last 10 lines lines:\n", @my_file[-10 .. -1];
}