use strict;
use warnings;

#Opening a File
open my $fh, '<', 'my_test2.pl';

#Opening a File for writing
open my $appfh, '>>', 'append.txt';

#Check for Errors
open my $fh, '<', 'my_test2.pl' or
 die "Cannot open file: $!";

# $! will tell why the file opening operation failed

#Reading from a file
my $all_line = <$file>;
my @all_lines = <$file>;

#Change the cursor position
seek($file, 0, 0); # Going to the begining

#Printing to a file
open $ofh, '>', 'output.txt' or ...;
print $ofh "Hello World!\n";