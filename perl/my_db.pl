use strict;
use warnings;

use DBI;

my $dbh = DBI->connect('dbi:mysql:test','root','')
 or die "Connection Error: $DBI::errstr\n";

my $sql = "select * from samples";

my $sth = $dbh->prepare($sql);
$sth->execute
 or die "SQL Error: $DBI::errstr\n";
 
while (my @row = $sth->fetchrow_array) {
	print "@row\n";
}