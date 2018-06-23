use strict;
use warnings;
use DBI;

my ($dbh, $sth, $firstname, $lastname, $destination,$rows);

$dbh = DBI->connect('dbi:mysql:test','root','')
 or die "Connection Error: $DBI::errstr\n";

$dbh->do("truncate table checkin1")
 or die "Couldn't truncate samples : $DBI::errstr\n";

$sth=$dbh->prepare("insert into checkin1 (firstname, lastname, destination)
                    values                (?       , ?       , ?)"); 
					
$rows=0;

while (<>) {
	chomp;
	($firstname, $lastname, $destination)=split(/:/);
	$sth->execute($firstname, $lastname, $destination)
	 or die "Couldn't insert record: $DBI::errstr\n";
	 
	$rows+=$sth->rows();
}
print "$rows row(s) inserted\n";