use strict;
use warnings;

my @unsorted = (1,2,11,24,3,36,40,4);

my @string = sort { $a cmp $b} @unsorted;
print "String sort: @string\n";

my @number = sort {$a <=> $b} @unsorted;
print "String sort: @number\n";

#split SEPERATOR STRING
my @vals = split ' ', $string;