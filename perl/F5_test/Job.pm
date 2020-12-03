package Job;

use version;
use feature qw{say};

our $VERSION=version->declare("1.0");
use threads;

sub new {
    my $invocant = shift;
    my $class   = ref($invocant) || $invocant;

    my $self = {
        env     => undef,
        prod    => undef, #prod - actually stands for 'process'
        ITsystem => undef, # ITsystem stands for "product". like vantive, ba and so on.
        account => undef,
        total_lines => undef,
        wrong_line => [],
        testfile => undef,
        cmd     => undef,
        proc=>undef, # pointer on instance of Proc::Reliable
        timeout=>undef,
        status  => undef,
        path=> undef,
        @_,
    };
    #bless $self, 'Job';
    return bless $self; #name of package received as first parameter hidded 
}

sub run {
    use Data::Dumper;
    my $self      = shift;
    my $FUNCNAME=(caller(0))[3];
    say $FUNCNAME;
    print Dumper $self;
    $self->{status}="RUN";
    system ($self->{cmd},$self->{path}) or return $self->{status}="FAILED";
    return $self->{status}=$?>>8;
    
}


1;