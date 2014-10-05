#use strict 'vars';
#use strict "refs";

#use strict 'subs';
#    $SIG{PIPE} = &Plumber; # blows up
#    $SIG{PIPE} = "Plumber"; # just fine: quoted string is always ok
#    $SIG{PIPE} = \&Plumber; # preferred form

#use sigtrap '' 

# print chart
# 2,5,3,1,4,8
# sub get_max - or we know max size
#@chart = (
#  [-2,1,0,0,0],
#  [-1,2,0,0,0],
#  [0,3,0,0,0],
#  [1,4,0,0,0],
#  [2,5,0,0,0],
#);

#regex return anonimous array
my $str = 'aa bb cccc';
print scalar( $str =~ /\w+/g);

#print 3, $a='aa'gorgeous
print $c=()=$str =~ /\w+/g;
#print 1, $c=1 !!! 
$c=$str =~ /\w+/g;



package AA;

sub new { return bless {}; }
sub foo { return 'A'; }


package B;
use base 'AA';

sub foo { return 'B'; }


package main;

my $obj = B->new();

print $obj->foo(), "\n";


#print values of two dimension array

$arr=[
  [1,4,5],
  [6,0,3]
 ];

# ссылка на массив ключей хэша %H
$rK = [keys %H];

sub func (){
    my %h=(a=>3,b=>5);
    
    return %h;
}


%h=(a=>1,b=>2);
my %a=func();

my $str = '1221333';
#\1 = $1 in left part of brackets
$str =~ s/(.)(.)\2/$1/g;

my @a = (1, 2, 3);
my ($a)= (1, 2, 3);

my $str = 'aa bb cccc';
my $val = () = $str =~ /\w+/g;
#3 - correct

$hash{undef} = undef;
$hash{''} = '';

################################
BEGIN {
    my $id = 0;
    sub nextval {
        $id++;
        return $id;
    }
}

#1 - correct
# this is case of closure. kind of static function
#################################

my $id = 2;
$id = nextval();
print $id;


package A;

sub new {
    my $class = shift;
    my $self = {};
    $self->init();
    return bless $self, $class;
};
  
sub init {
    my $self = shift;
    $self->{key} = 'value';
}
 
sub get {
    my ($self, $key) = @_;
    return $self->{$key}; 
}
 

package main;

my $obj = A->new();
print $obj->get('key'), "\n";



print foo();

sub foo { $a=5; $b=$a+1; }
#will print 6 - res of last expression

#########################
my $a = (0, 1, 2);
#my $a=[0,1,2];
print "$a\n";
#2 - last value. scalar
#########################
my $str = '112133';
$str =~ s/(.)\1/$1/g;
#1213 - correct  this finds pairs of characters and replaces them with a single instance
#########################


#	A #description: bless() with omitted class name uses the name of the current package, so new() in this code always creates instances of A
###########################

my $var;

if (exists $var->{key1}->{key2}) {
    $var->{key1}->{key2} = 1;
}

my $keys = keys(%{$var});

sub func {
    $a=5;
    $a=7
}

print func();

@in=(2,4,1,8,5);
$max=8;
#
for ($j=$max;$j>=0;$j--){
    for($i=0;$i<@in;$i++){
        $chart[$j][$i]=($max-$in[$i]-$j-1 <0 )?'* ':'  ';
    }
}

for($j=0;$j<$max;$j++){
    foreach(@{$chart[$j]}){
        print
    }
    print "\n";
}
   
# 1,2,3,5,6,7,8,10,12,13 -> 1-3, 5-8,10,12-13

@in=(1,2,3,5,6,7,8,10,12,13);

@dir=(<../Perl/*.pl>);
print