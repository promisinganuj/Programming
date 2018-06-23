use strict;
use warnings;

my ($value, $from, $to, $rate, %rates);
%rates = (pound => 1, dollars => 1.6, "francs" => 2.30);

print "Enter the starting currency: ";
$from = <STDIN>;
print "Enter the starting currency: ";
$to = <STDIN>;
print "Enter the amount: ";
$value = <STDIN>;

chomp($from, $to, $value);

if ($rates{$from} && $rates{$to} ) {
$rate = ($rates{$from} / $rates{$to}) * $value;
print $rate;
}
else
{ print "Undefined currency\n";
}
