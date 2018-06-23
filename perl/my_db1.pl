use strict;
use warnings;

use DBI;
my $max_val = 0;

my $dbh = DBI->connect('dbi:mysql:test','root','')
 or die "Connection Error: $DBI::errstr\n";

my $sth = $dbh->prepare("select * from samples");
$sth->execute
 or die "SQL Error: $DBI::errstr\n";

while (my @row = $sth->fetchrow_array) {
	print "@row\n";
	$max_val = $row[0] + 1;
}

$dbh->do("TRUNCATE TABLE samples")
 or die "Couldn't truncate samples : $DBI::errstr\n";

$sth = $dbh->prepare("insert into samples values ($max_val,'Sundar')");
$sth->execute
 or die "SQL Error: $DBI::errstr\n";

$sth->finish;
 
my $rows=$dbh->do("insert into samples values ($max_val + 1, 'Tom')")
 or die "Couldn't insert record : $DBI::errstr\n";

print "$rows row(s) added to samples\n";
 
$dbh->disconnect
 or die "SQL Error: Failed to disconnect\n";

print "Exiting...\n";