use strict;
use warnings;

my %where = (Gary => "Dallas", Lucy => "Exeter", Ian => "Reading", Samantha => "Oregano");

my @where = %where;
print "@where\n";

if (exists $where{"Gary"}){
	print "Gary upasthit hai\n";
}

print "Hash keys are", keys(%where), "\n";
print "Hash values are", values(%where), "\n";