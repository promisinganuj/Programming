use strict;
use warnings;

my $logging = "file";

if ($logging eq "file"){
	open LOG, "> output.log" or die $1;
	select LOG;
}

print "Program started: ", scalar localtime, "\n";
sleep 30;
print "Program started: ", scalar localtime, "\n";

select STDOUT;