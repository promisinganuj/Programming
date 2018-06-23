use strict;
use warnings;
use DBI;

my ($dbh, $sth);

sub count_table{
	my($dbh, $table, $sql, @values)=@_;
	
	$sql="" unless defined $sql;
	my $sth=$dbh->prepare("SELECT COUNT(*) from $table $sql")
	 or die "Prepare failed: $DBI::errstr\n";
	 
	$sth->execute(@values)
	 or die "Execute failed\n";
	 
	return ($sth->fetchrow_array())[0];
}

$dbh=DBI->connect('dbi:mysql:test','root','')
 or die "Connection Error: $DBI::errstr\n";
 
 print count_table($dbh, "checkin1");
 print "\n";
 print count_table($dbh, "checkin1", " where destination='roorkee'");
 print "\n";
 print count_table($dbh, "checkin1", " where destination=?","mumbai");
 print "\n";