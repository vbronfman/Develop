package A;

sub new { return bless {}, shift };
sub foo { return 'A' }


package B1;
use base 'A';

sub foo { return 'B1' }


package B2;
use base 'A';

sub foo { return 'B2' }


package C;
use base 'B1', 'B2';


package main;

my @a = ([1, 2, 3, 4], [5, 6, 7, 8]);
print join(' ', @{$a[1]}[1..3]);
my $obj = C->new();

print $obj->foo(), "\n";
###################################

my $a = 123456;
my $b = 123_456;

if ($a == $b) {
    print "same";
} else {
    print "different";
}

###################################
my $str = 'aa bb cccc dd';
print $val = ()=$str==~ /\w+/g;;

###################################
use strict 'refs';   

sub foo { return "func" }

my $func='foo';


$bar=\&$func;
print &$bar;
$bar = \&{'foo'};
    &$bar;
    
########################################

#What gets printed?

@a = ([1, 2, 3, 4], [5, 6, 7, 8]);

print join(' ', @{$a[1]}[1..3]);

#	1 2 3
#	2 3 4
#	5 6 7
#	6 7 8 - correct
#	the code will fail
#
#description: the second element (index 1) in the array @a is a reference to an anonymous array, which is dereferenced by @{}, and then the slice [1..3] is taken

#############################################################

package A;

sub new { return bless {}, shift; }
sub DESTROY { print ref(shift); }


package B;
use base 'A';

sub DESTROY {
    my $self = shift;
    print ref($self);
    bless $self, 'A';}


package main;

my $obj = B->new();

############################################################


my $var = 1;
$main::var = 2;

if ($var == $main::var) {
  print 'true';
} else {
  print 'false';
}
