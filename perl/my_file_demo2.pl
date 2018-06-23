use strict;
use warnings;

my $lineno = 1;
my $current = "";

while (<>) {
	if ($current ne $ARGV) {
		$current = $ARGV;
		print "\n\t\tFile: $ARGV\n\n";
		$lineno=1;
	}
	print $lineno++;
	print ": $_";
}
