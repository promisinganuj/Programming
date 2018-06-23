use strict;
use warnings;

#my $source = shift;
my $source = shift @ARGV;
#my $destination = shift;
my $destination = shift @ARGV;

open IN, '<', $source or 
 die "Cannot open file: $!";

#Check for Errors
open OUT, '>', $destination or
 die "Cannot open file: $!";

my @temp;

#@temp = <IN>;
while (<IN>){
	push @temp, $_;
}

print OUT sort (@temp);