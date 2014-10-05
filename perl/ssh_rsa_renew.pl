#!/usr/bin/perl

#############################################
# <script name> - Monitor the status of Product line
# and send notification
#
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################
use lib "/ITLAB_share/itlab/perl/lib";

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use XML::DOM;

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=0;
@TO_RUN ;

package Job;

sub new {
    my $self = {
        env     => undef,
        prod    => undef, #prod - actually stands for 'process'
        ITsystem => undef, # ITsystem stands for "product". like vantive, ba and so on.
        _account => undef,
        _db => undef,
        _cmd     => undef,
        proc=>undef, # pointer on instance of Proc::Reliable
        timeout=>undef,
        status  => undef,
        value=>'TEST_VALUE',
    };
    #bless $self, 'Job';
    return bless $self; #name of package received as first parameter hided 
    #return $self;
}

package main;


#######################################
# functions
#######################################

#######################################
# sig_handler() - catch INT signal
#  
#sigtrap - Perl pragma to enable simple signal handling
#use sigtrap 'handler' => \&my_handler, 'normal-signals';
#######################################
sub sig_handler
{
    print STDERR "INT signal received!!!\n";
    die "\n caught $SIG{INT}",@_,"\n";
    #exit;
  
}
#######################################
# func() - <description>
#
#######################################
sub func(){
$RET=0;
$FUNCNAME=(caller(0))[3];
#excecute command    

$RET=$?;

    if ($RET ne 0){
        writelog "$FUNCNAME FAILURE $RET"
        }
    else {
        writelog "$FUNCNAME SUCCESS"
    }

return $RET;
}


sub usage
{
    $str=<<END;
$0 - help to update connection without password: copy ~/.ssh/id_rsa.pub to remote hosts

cat ~/.ssh/id_rsa.pub | ssh oracle@vmbatest3 'cat >> ~/.ssh/authorized_keys'

Usage:
 $0 <config_file>
 where
    
 
For ex.
 $0 /ITLAB_share/itlab/Monitor/monitor_conf.xml

END

    Partner::Init::usage ($str);
}


sub AUTOLOAD {
use Carp;
croak "Function $AUTOLOAD not defined!";
#confess;
#warn "Function $AUTOLOAD not defined!";
    
}




#######################################
# read_conf() - read in configuration by XML::Simple
#my $simple = XML::Simple->new( ); # initialize the object 
#
#######################################
sub read_conf($){
    
    use XML::Simple;
    
    $RET=0;
    $FUNCNAME=(caller(0))[3];
    
    
    
    my($FILENAME)=@_;
    
    writelog "$FUNCNAME Parse by XML::Simple\n";
    
    my $conf = XML::Simple->new( ); # initialize the object
    #my $tree = $conf->XMLin( $FILENAME, ForceArray => [ 'products','product','environment' ] );
    my $tree = $conf->XMLin( $FILENAME); # read, store document
    
    #print Dumper($tree);
    
    foreach $prod (  keys %{$tree->{products}->{product}} ) 
    {
        print Dumper $prod;
        next if($tree->{products}->{product}->{$prod}->{state} eq "disabled");
    
        foreach $key ( $tree->{products}->{product}->{$prod}){
                   
            $ref=$key->{environment}; #must be defined as global in next version
            
            print $key->{cmd}->{content}, "\n";

# Collects definiton of environment                    
            foreach $ENVkey (@$ref){
                next if ($ENVkey->{state} eq "disabled");
                my $job=Job->new;
                $job->{prod}=$prod;
                
                unless (exists $key->{ITsystem} ){
                    $job->{ITsystem}=$prod;
                }
                else {
                    $job->{ITsystem}=$key->{ITsystem};
                }
                           
                $job->{env}=$ENVkey->{env};
                $job->{timeout}=$key->{cmd}->{timeout};
                $job->{_db}=$ENVkey->{db};
                
                local $DB=$ENVkey->{db}; #value to replace for in string from config file
                local $ENV=$ENVkey->{env};

# Variables substitution 
                chomp '"'.$key->{cmd}->{content}.'"';
                $job->{_cmd}=eval('"'.$key->{cmd}->{content}.'"'); #replace and assign the value
                
                #push @TO_RUN, \$job;
                
  #Handle of a case of more than one account per product 
            if((ref $ENVkey->{account}) eq "ARRAY"){
                foreach $str (@{$ENVkey->{account}}){
                 print "$str\n";
                 $job->{_account}=$str;
                 push @TO_RUN, $job;
                }
                #print $ENV->{account}->[0], "\n";
                #print $ENV->{account}->[1], "\n";    
                
            }else{
                print $ENVkey->{account}, "\n";
                $job->{_account}=$ENVkey->{account};
                push @TO_RUN, $job;
            }              
            
            }       
        }
    }
    
    @TO_RUN=sort {print;
                  #${$a}->{env} cmp ${$b}->{env}} @TO_RUN;
                  ${a}->{env} cmp ${b}->{env}} @TO_RUN;
    
    #print Dumper (@TO_RUN);
    
    #Notification properties, kind of global
        #$ref=$tree->{mail}->{sendto}->{recipient}; #pointer into list of recepients
        #$template_dir=$tree->{mail}->{template_dir};
        #$template_file=$tree->{mail}->{out_html};
        #$input_template=$tree->{mail}->{input_template}; 
        #$out_html=$tree->{mail}->{out_html};
        #
        #$subject_file=$tree->{mail}->{subject_file};
    
 #   use XML::DOM;
 #
 #my $parser = new XML::DOM::Parser;
 #my $doc = $parser->parsefile ($FILENAME);
 #
 ## print all HREF attributes of all CODEBASE elements
 #my $nodes = $doc->getElementsByTagName ("product");
 #my $n = $nodes->getLength;
 #
 #for (my $i = 0; $i < $n; $i++)
 #{
 #    my $node = $nodes->item ($i);
 #    my $href = $node->getAttributeNode ("account");
 #    print $href->getValue . "\n";
 #}
 #
 ## Print doc file
 #$doc->printToFile ("out.xml");
 #
 ## Print to string
 #print $doc->toString;
 #
 ## Avoid memory leaks - cleanup circular references for garbage collection
 #$doc->dispose;
 #
    return $RET;
}


#######################################
# main
#######################################

main::usage($str) unless @ARGV;


#my()=@ARGV;
my($CONF_FILE)=@ARGV;
initlog ($LOG);

writelog ("Started");

writelog (DEBUG,"debug message");

read_conf($CONF_FILE);
writelog ("Prepare list of accounts");

#die "Public key $ENV{HOME}/.ssh/id_rsa.pub not found" unless (-f "$ENV{HOME}/.ssh/id_rsa.pub");

#Copies of public key onto all destination hosts
foreach $job (@TO_RUN){
   writelog("$job->{_account}");
   qx { cat $ENV{HOME}/.ssh/id_rsa.pub | ssh $job->{_account} 'cat >> ~/.ssh/authorized_keys'  };
   writelog("Result of : $! ");
    
}

writelog ("Finished");


closelog;
exit $RET;

