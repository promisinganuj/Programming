use strict;
use warnings;

my $source = shift @ARGV;
my $destination = shift @ARGV;

open IN, '<', $source or 
 die "Cannot open file: $!";

#Check for Errors
open OUT, '>', $destination or
 die "Cannot open file: $!";

while (<IN>){
		print OUT $_;
}