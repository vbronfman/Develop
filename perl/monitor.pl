#!/usr/bin/perl -I .

#############################################
# <script name> - Monitor the status of Product line
# and send notification
#
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################


use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use XML::Simple;

require "monitor_html.pl";
do "send_notification.pl";

#use sigtrap 'handler', \&sig_handler, 'normal-signals';

$TIMEOUT=120; #in sec


#######################################
# Global variables
#######################################
use constant {  SUCCESS    => 0,
                WARNING    => 3,
                FAILED     => 1,
                TIMED_OUT  => 4,
            };   

$LOG="${0}_$$.log";
$DEBUG=(defined($ENV{DEBUG}))?$ENV{DEBUG}:0;

%DEFINITIONS={};

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


sub params {
$self=shift; #package name

foreach $key ( keys %$self  ){
    print $self->{$key};
    push @OUT,$self->{$key};
}

return @OUT;
}

################################################################################


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
# run_cmd() - <description>
# not in use, obsolete
#######################################
sub run_cmd($$){
    my($account,$cmd)=@_;
    $RET=0;
    $FUNCNAME=(caller(0))[3];
    print "Inside $FUNCNAME $account,$cmd\n";
    #$cmd =~ s/(\$\w+)/$1/gee;
    
    #excecute command
    $RET=system("ssh",$account,$cmd) or warn "system ssh,$account,$cmd failed: $?";
    print "ret=$RET, ?=$? ret>>8= ", $?>>8;
    return $RET>>8;
}


#######################################
# on_exit() - called after signal
#
#######################################
sub on_exit{
    $RET=0;
    $FUNCNAME=(caller(0))[3];
    
    writelog "$FUNCNAME called on signal, $0 terminated";
    
    #in temporary way!!! should  elaborate
    #send_notification($main::CONF_FILE, "$0 terminated by timeout");
    
    die "Terminated\n\n";
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
        
#File contains formated output.         
        $out_html =(defined $out_html)?$out_html:$tree->{mail}->{out_html};
        writelog "\n\n out_html11 = $out_html \$template_dir=$template_dir \$tree->{mail}->{out_html} = $tree->{mail}->{out_html}\n\n";
        $subject_file=$tree->{mail}->{subject_file};
        
# SSH connection definions
#backward compatibility to prevent fault 
eval {
        $SSH_file=$tree->{remote_cmd}->{ssh_file};
        $SSH_options=$tree->{remote_cmd}->{ssh_options};
};
    return $RET;
}

#######################################
# usage() - print usage
#
#######################################
sub usage
{
    $str=<<END;
$0 - simple sw products monitor. By ssh initiates and collects responses of scripts of monitoring at target hosts.

Usage:
 $0 <configuration file> [html_out]
 where
    configuration file - XML file defines products to check, working environments per product
                        credentials and command to run at remote host.
    html_out - file to send output into. override value of "out_html" section of configuration file
 
For ex.
 $0 monitor_conf.xml

END

    Partner::Init::usage ($str);
}

#######################################
# run_cmd_multi() - print usage
#
#######################################
sub run_cmd_multi
{
    #to avoid error on Win32 should be uncommented prior deploy into environment!!!!
    use No::Worries::Proc qw(proc_run proc_create proc_monitor proc_detach);
    ###### require No::Worries::Proc  ; #to avoid error on Win32 should be commented prior deploy into environment!!!!
    my($account, $cmd, $timeout)=@_;
    $FUNCNAME=(caller(0))[3];
#    print "ACCOUNT=$account, \$cmd = $cmd ";

 # start two process and wait for them to finish
   # my$output="/dev/null";
    my$output="./monitor.proc";
$timeout=$TIMEOUT unless (defined $timeout && $timeout!=0);
writelog("timeout = $timeout");
  my $proc = proc_create(
#    command => ['/usr/bin/ssh','-vv',$account,$cmd],
#    command => ['ssh',$account,$cmd],
    command => ['/usr/bin/ssh',
#'-o "ControlMaster=yes"', 
#'-o "ControlPath=$HOME/.ssh/ctl/%r@%h:%p"',
#"-M -S $HOME/.ssh/ctl/$account",
#"-S $HOME/.ssh/ctl/$account",
#'-T',
$account,
$cmd],

    #timeout => 7,    # to be killed if still running after 5s
    timeout => $timeout,    # to be killed if still running after 5s
    stdout  => \$output,    # get stdout+stderr in $output
    stderr  => "",          # merge stderr with stdout
  );

 print "$FUNCNAME COMMAND= ",@{$proc->{command}} ,"\n timeout = $proc->{timeout}";
print "STATUS  $proc->{status}";


 #using Proc::Simple

   #use Proc::Simple;
   #$proc = Proc::Simple->new();        # Create a new process object
   ##$proc->kill_on_destroy(1);
   #$status=$proc->start("ssh",$account,$cmd);
   #unless ($status){
   #     print "Error starting $cmd\n " #add 
   #}
############################################

#using Proce::Reliable
#use Proc::Reliable;
#Create a new process object
 
 #my ($account,$cmd)=@_;
 #  $myproc = Proc::Reliable->new();
 #  
 #  $myproc->want_single_list(0);
 # #my ($stdout, $stderr, $status, $msg) = $myproc->run("ssh",$account,$cmd);
 # $myproc->run("ssh",$account,$cmd);
 ##$status=$status>>8;
 ##print "status= $status, $msg";
#############################################


return $proc;
       
}


#######################################
# send_notification () - <description>
# $FILENAME - configuration file
#######################################
sub send_notification{
    my($FILENAME,@text)=@_;
$RET=0;
$FUNCNAME=(caller(0))[3];

#my $conf = XML::Simple->new( ); # initialize the object
#my $tree = $conf->XMLin($FILENAME);
 
print "$FUNCNAME ", @text;

#excecute command
#$ref=$tree->{mail}->{sendto}->{recipient}; #pointer on list of recepients
#$template_file=$tree->{mail}->{out_html};
#$subject_file=$tree->{mail}->{subject_file};

#$ref points at array of recepients, won't send in case of empty array


if(@$ref){
send_mail($template_file, $subject_file ,join(',', @$ref),@text) ;
}
}



#######################################
# main
#######################################

main::usage($str) unless @ARGV;

($CONF_FILE,$out_html)=@ARGV;

initlog ($LOG);
#initlog ;

writelog ("Started");

read_conf($CONF_FILE);

### run tests  ######

#push @mail_body,"\<table border=\"1\"\> ";
#push @mail_body,$STR;

local $max_timeout=0;
@proc=();

$counter=0;

foreach $job (@TO_RUN){

	$job->{proc}=run_cmd_multi ($job->{_account}, $job->{_cmd},$job->{timeout} );
print Dumper($counter++, "DUMP ",$job->{proc});
    push @proc,$job->{proc};



    $max_timeout=$job->{timeout} if ($max_timeout<$job->{timeout});
}

#Wait for the given process(es) (as created by proc_create())
$max_timeout=120 if($max_timeout <=0);
writelog ("major timeout = $max_timeout");
proc_monitor(\@proc, timeout => $max_timeout, bufsize=>16384);

#use Time::HiRes ;
#
#sub timeout {   my $timeout = shift;   my $poll_interval = shift;   my $test_condition = shift;
#             until ($test_condition->() || $timeout <= 0) {
#                $timeout -= $poll_interval;
#                sleep $poll_interval;
#                                                           }
#             return $timeout > 0; # condition was met before timeout
#             }
##my $success = timeout(30, 0.1, \&some_condition_is_met);
#$f=sub{return 0};
#my $success = timeout(30, 0.1, \&$f );
#             
#print "\n\n\nBefore sleep\n";
##print "slept sec =", sleep; 
#print "\n\n\nAfter sleep\n";

foreach $job (@TO_RUN){
    print "ACCOUNT=$job->{_account}  CMD= $job->{_cmd}  status=$job->{proc}->{status}\n ";
    
    unless ($job->{proc}->{timeout}) {

#resolution of return code

         $job->{status}=($job->{proc}->{status})>>8;

	#if($job->{proc}->{status} < 256){
	#	$job->{status}=$job->{proc}->{status}; #as is returned after system call
	#}
	#else{
	#($job->{proc}->{status})>>=8;
	#writelog("DEBUG $job->{prod} \$job->{proc}->{status}=",$job->{proc}->{status},"\n");

       #$job->{status}=($job->{proc}->{status} & 0x80) ? -(0x100 - ($job->{proc}->{status} & 0xFF)) : $job->{proc}->{status};

       #writelog("DEBUG $job->{prod} \$job ->{status}=",$job->{status},"\n");
    #}
}
    else{
        writelog("job timed out");
        $job->{status}=TIMED_OUT; #timed out
    }

   # if ($job->{proc}->status)
   
   #print "job->status = $job->{status}";
   #unless ($job->{status})
   #{
   #     $job->{status}=SUCCESS; #0 - is UP
   #     print "Ok\n";
   # }
   # else{
   #     $job->{status}=FAILED; # 1- is "DOWN"
   #     print "Failed\n"
   # }
    
    print Dumper $job;
}
#end of debug only       
     
#Prepare mail body by Template module
# TO_RUN contains data of each job including status

#foreach $job (@TO_RUN){
    
#   unless(run_cmd ($$job->{_account}, $$job->{_cmd})){
 #   unless(run_cmd ($job->{_account}, $job->{_cmd}))
  #  {
#        $$job->{status}=1; #1 - is UP
        
#                $STR=<<END;
#        <tbody align="center" style=" color:black; background-color:green">
#        <tr>
#<td> $$job->{env} </td>
#<td> $$job->{prod} </td>
#<td> $$job->{_account}  </td>
#<td> $$job->{status} </td>
#</tr>
#</tbody>
#END
#        
   # }
    #else
    #{
#        $$job->{status}=0; # 0- is "DOWN"
    
#        $STR=<<END;
#        <tbody align="center" style=" color:black; background-color:yellow">
#            <tr>
#                <td> $$job->{env} </td>
#                <td> $$job->{prod} </td>
#                <td> $$job->{_account}  </td>
#                <td> $$job->{status} </td>
#            </tr>
#        </tbody>
#END
    #}
   # push @mail_body,$STR;
#}

#push @mail_body,"</table>";

#$STR=<<END;
#<br>
#<br>IT-Lab Team
#END
#
#push @mail_body,$STR;
### end of create mail ######

create_html();

send_notification($CONF_FILE, @mail_body);

writelog ("Finished");

closelog;
exit $RET;
