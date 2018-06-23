use strict;
use warnings;

print "***************\n";

#@lets[2,4] => Give me 2nd and 3rd
#@lets[1..3] => Give me 2nd till 4th element
my @lets = ('a', 'b', 'c', 'd', 'e');
print @lets[1,4], "\n";
print (("a", "b", "c", "d")[-2,3]), "\n";
print "Going for 3 to z:",(3 .. 'z'), "\n";
print "Going for z to 3:",('z' .. 'z'), "\n";

my $hand;
my @pileofpaper = ("Letter", "newspaper", "gas bill", "notepad");
$hand = pop @pileofpaper;
print "$hand,\n";

push @pileofpaper, "Anuj", "Ram";
print @pileofpaper;