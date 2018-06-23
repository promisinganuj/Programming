use warnings;
use strict;

my $total=0;
$total += $_ for @ARGV;

print "$total.\n";
print @ARGV;