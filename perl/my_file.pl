use strict;
use warnings;

my $target;

while (1) {
	print "What file should I write on? ";
	$target = <STDIN>;
	chomp($target);
	if (-d $target) {
		print "No, $target is a directory.\n";
		next;
	}
	if (-e $target) {
		print "File already exists, what next?\n";
		print "Enter 'r' to write to a different name, ";
		print "'o' to override or \n";
		print "'b' to back up to $target.old)\n";
		my $choice = <STDIN>;
		chomp $choice;
		if ($choice eq "r") {
			next;
		} elsif ($choice eq "o") {
			unless (-o $target) {
				print "Can't overwrite $target, it's not yours.\n";
				next;
			}
			unless (-w $target) {
				print "Can't overwrite $target.\n";
				next;
			}
		} elsif ($choice eq "b") {
			if (rename($target, $target.".old")) {
				print "ok, moved $target to $target.old\n";
			} else {
				print "I didn't understand that answer.\n";
				next;
			}
		}
	last if open OUTPUT, "> $target";
	print "I couldn't write on $target: $!\n";
}}
print OUTPUT "Congratulations.\n";
print "wrote to file $target\n";
