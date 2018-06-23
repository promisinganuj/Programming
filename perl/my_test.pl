use strict;
my @a = ("This is the ", 1 , "st array");
print @a,"\n";
$a[1] = 20;
print $a[2],"\n";
print $a[1],"\n";
my $foo = @a;
print $foo,"\n";
print $a,"\n";
$a[1] = "";
print @a,"\n";

print "***************";

my @in = (25, 50,75);
my @out = ('a', 'b', (3, 4), @in, 'd');
print @out,"\n";

print "***************\n";

#Last index of the array
print $#in,"\n";
$#in=1;
print $#in,"\n";
$in[2]=50;
print @in,"\n";

print "***************\n";

#@lets[2,4] => Give me 2nd and 3rd
#@lets[1..3] => Give me 2nd till 4th element
my @lets = ('a', 'b', 'c', 'd', 'e');
print @lets[1,4];
