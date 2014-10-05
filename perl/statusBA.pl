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

eval {require Partner::Init};
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
########################################
## func() - <description>
##
########################################
#sub func(){
#$RET=0;
#$FUNCNAME=(caller(0))[3];
##excecute command    
#
#$RET=$?;
#
#    if ($RET ne 0){
#        writelog "$FUNCNAME FAILURE $RET"
#        }
#    else {
#        writelog "$FUNCNAME SUCCESS"
#    }
#
#return $RET;
#}


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

#    Partner::Init::usage ($str);
}


#######################################
# main
#######################################

main::usage($str) unless @ARGV;

#my()=@ARGV;
$RET=0;

#HTTP_Server        |    5413 | Alive   
#dcm-daemon         | dcm-daemon         |     N/A | Down    
#OC4J               | home               |    5414 | Alive   
#OC4J               | OC4J_BI_Forms      |    5415 | Alive   
#rep_vmbatest3_ora~ | ReportsServer      |    5588 | Alive   

@chk_resource=(@ARGV == 1)?($ARGV[0]):qw{HTTP_Server home OC4J_BI_Forms ReportsServer};
$CMD="opmnctl status -fsep \':\' -fmt %prt%sta -noheaders";
#$out=`$CMD`;
for $str (`$CMD`){
chomp $str;
#print "str = $str \n";
#print split(/:/,$str);
($process_type,$status)=split(/:/,$str);
#print "process_type=$process_type\n";
    #print "PROC=$process_type status - $status\n"  unless grep /$process_type/ ,@chk_resource;
    next unless grep /$process_type/ ,@chk_resource;
    #print "Down $process_type \$status = $status \n"  if ($status=~!/Alive/);
    exit 1  if ($status=~!/Alive/);
    #exit 1 if $status ne 'Alive';
}


exit $RET;
