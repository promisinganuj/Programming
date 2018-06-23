use strict;
use warnings;

open FILE, "my_file_demo.pl" or die $!;
my $lineno=1;

print $lineno++, ": $_" while <FILE>

