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

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use XML::Simple;

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=0;
$STARTEAMSERVER="starteam1";
$STARTEAMSERVERPORT="49201";


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


#######################################
# read_conf() - read in configuration by XML::Simple
#my $simple = XML::Simple->new( ); # initialize the object 
#
#######################################
sub read_conf($){
$RET=0;
$FUNCNAME=(caller(0))[3];
#excecute command    
my($FILENAME)=@_;

my $conf = XML::Simple->new( ); # initialize the object
my $tree = $conf->XMLin( $FILENAME ); # read, store document


## my $ref = XMLin($FILE);
##my $xs = XML::Simple->new(options);
print "Parse by XML::Simple\n";
my $xs = XML::Simple->new();
my $ref = $xs->XMLin($FILENAME);
#
print Dumper($ref);
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


#######################################
# main
#######################################

main::usage($str) unless @ARGV;

my($CONF_FILE,$STARTEAM_USER,$ST_PASSWD)=@ARGV;

initlog ($LOG);

writelog ("Started");

writelog (DEBUG,"debug message");

$ST_CONNECTION_STRING="$STARTEAM_USER:$ST_PASSWD\@$STARTEAMSERVER:$STARTEAMSERVERPORT";

open (FILE, "<",$CONF_FILE) or die "can not open $CONF_FILE: $!";

foreach $str (<FILE>){
    next if $str=~/^$/;
    chomp $str;
    ($STARTEAM_PROJ,$FILENAME,$LABEL_NAME)=split(/;/,$str);
    #get from starteam
    $STARTEAM_PROJ=~s/\w:\/(.*)\/.*\.sql/$1/i;
    $LABEL_DIR="/home/test_user/Develop/GET_BILLING_VER";
   $CMD="stcmd co -p \"$ST_CONNECTION_STRING/$STARTEAM_PROJ/$STARTEAM_VIEW\" -vl ${LABEL_NAME} -stop -nologo -eol lf -o -fp ${LABEL_DIR} -is -fs  -ts -x";
 #   $CMD="stcmd co -p $ST_CONNECTION_STRING/$STARTEAM_PROJ/$STARTEAM_VIEW -vl ${LABEL_NAME} -stop -nologo -eol lf -o -is -fs  -ts -x [files]";

    writelog $CMD;
    system($CMD) or warn "Error while system $CMD:$!"
}

close FILE;
writelog ("Finished");


closelog;
exit $RET;

