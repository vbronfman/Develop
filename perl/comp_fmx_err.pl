#!/usr/bin/perl

#############################################
# comp_fmx_err - pull out error message from log of comp_all.sh
#
# Developed by V.Bronfman at 10/06/2013
# Comments:
# Dependencies:
#
#############################################

use lib "D:/Develop/Perl/perl/lib";
use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=0;
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
$0 - <description>

Usage:
 $0 <parameteres>
 where
    
 
For ex.
 $0 

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
        $ref=$tree->{mail}->{sendto}->{recipient}; #pointer into list of recepients
        $template_dir=$tree->{mail}->{template_dir};
        $template_file=$tree->{mail}->{out_html};
        $input_template=$tree->{mail}->{input_template}; 
        $out_html=$tree->{mail}->{out_html};
        
        $subject_file=$tree->{mail}->{subject_file};
    
    return $RET;
}


#######################################
# main
#######################################

main::usage($str) unless @ARGV;

my ($file) = @ARGV;

initlog ($LOG);

writelog ("Started");

writelog (DEBUG,"debug message");

open (IN,$file) or die "cann't open $file: $?";

$section =0;
my @log=();
my %FMB=();

while(<IN>){
    #chomp;

    if(~/compiling (.*\.fmb)/ || $section ) { #'Form not created'
        $fmb=$1;
#        print;
          push @log,$_;
        
        if(/Created form file /){
            $FMB{$fmb}=undef ;# success
            $section=0;
            @log=();
            next;
        }
        elsif (/Form not created/){
            @{$FMB{$fmb}}=@log;
            $section=0;
            @log=();
            next;
        }
    }
    
}

close IN;

my $errors_num=0; 
while (($key, $value) = each %FMB) {
  
    if (defined $value){
        $errors_num++;
        
        print "#"x30,"\n","$key\n","#"x30,"\n";
        #print @$value ;
        for(my $i=0; $i<@$value;$i++){
            next if ($value->[$i]=~/^$/ || $value->[$i+1]=~/^$/ || $value->[$i+1]=~/No compilation errors/); 
            print $value->[$i]."\n";
        }
   }
}

writelog ("Numbers of errors is $errors_num ");
writelog ("Finished");

closelog;
exit $RET;

