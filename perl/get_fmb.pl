#!/usr/bin/perl

#############################################
# get_fmb.pl - check out of fmb files from Starteam by label
#
# Developed by Vlad_Bronfman at 090512
# Comments:
# Dependencies: Partner/Init.pm
#               stcmd - command line interface of Starteam
#               ssh/scp
# Restrictions: UNIX/Linux only, depends on find command
#############################################

use Partner::Init;
use File::Copy;
use File::Find;
use File::Basename;

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################

#$SIG{INT}=\&sig_handler;

$LOG="${0}.log";
$DEBUG=1;

#$STARTEAMSERVER=$ENV{STARTEAMSERVER} // "starteam1";
#$STARTEAMSERVERPORT=$ENV{STARTEAMSERVERPORT}//"49201";
#$STARTEAM_USER=$ARGV[2] // $ENV{$LOGNAME};
$STARTEAMSERVER="starteam1";
$STARTEAMSERVERPORT="49201";

$ST_PASSWD="";
${ST_CONNECTION_STRING}="$ST_USER/$ST_PASS\@$ST_SERVER:$ST_PORT";

$STARTEAM_PROJ="BillingMigration";
$STARTEAM_VIEW="10gba";
#${ST_LABEL}=$ARGV[0] // "";
#$LABEL_DIR= $ARGV[1] // "";

local (
    $ENV,
    $ST_LABEL,
    $LABEL_DIR,
    $STARTEAM_USER,
    $STARTEAM_PASSWD
    ) = @ARGV;

$ENV=uc $ENV;

#$DEST_DIR="${ORACLE_HOME}/myforms";
$WORK_DIR="";

%BA_SERVERS = (
    TST1 => ["oraias\@it2tst1","myforms", "reports/reports\@bscstst1"],
    #TST1 => "oraias\@it2tst1",
    TST3 => ["oracle\@vmbatest3","myforms", "reports/reports\@bscstst3"],
    TRAIN2 => ["oracle\@baclass","myforms", "reports/reports\@bstrain2"],
    TRAIN3 => ["oracle\@baclass","myforms3", "reports/reports\@bstrain3"],
 );

$USAGE=<<USAGE;
$0 - check out of fmb files from Starteam by label, deploys to remote host and perform
compilation with frmcmp

Usage:
 $0 <ENVIRONMENT> <ST_LABEL> <LABEL_DIR> [STARTEAM_USER][STARTEAM_PASSWD]
 where
 ENVIRONMENT - TST1,TST3,Train1,Train2
 LABEL_DIR - full path of folder that contain files had been checked out.
    
 
For ex.
 $0 TST1 10g_20120422 $HOME/VERSION/10g_20120422 vbronfman passwd

USAGE


#######################################
# functions
#######################################

#######################################
# sig_handler() - catch INT signal
# not works properly yet...
#
#######################################
sub sig_handler
{
    print STDERR "INT signal received!!!\n";
    closelog;
    die "\n caught $SIG{INT}",@_,"\n";
    #exit;
    #sigtrap - Perl pragma to enable simple signal handling
    #use sigtrap 'handler' => \&my_handler, 'normal-signals';
}

#######################################
# cp_fmb() - copy *fmb files to remote host by scp
#
#######################################
sub cp_fmb($$){

my ($ENV,$DEST_DIR)=@_;

$RET=0;
$FUNCNAME=(caller(0))[3];

unless( exists $BA_SERVERS{$ENV}) { writelog "There is no key ${ENV} in hash \%BA_SERVERS ";  return 1;}

writelog ("INFO Going to copy *fmb to $BA_SERVERS{$ENV}->[0]:${DEST_DIR} ");
#excecute command
#find /home/test_user/VERSION -name "*fmb" -type f | xargs -I {} scp "{}" "oraias@it2tst1":/tmp
#find used just in way to speed up development
#$CMD=qq { find ${LABEL_DIR}/ALL_FMB -name \"*fmb\" -type f | xargs -I {} scp -p "{}" "$BA_SERVERS{$ENV}":${DEST_DIR} };
#scp -prq

#copy files one by one - ugly, but I too lazy now for think about
foreach $file (@main::fmbs){
    $CMD=qq { scp -p "$file" "$BA_SERVERS{$ENV}->[0]":${DEST_DIR} };
    
    writelog "DEBUG cmd=$CMD";
    
    writelog `$CMD`;
    
    $RET=$?>>8;
    
        if ($RET ne 0){
            writelog "$FUNCNAME FAILURE $RET"
            }
        else {
            writelog "$FUNCNAME SUCCESS"
        }
}

return $RET;
}


#######################################
# compile_fmb() - run frmcmp.sh on remote host by ssh
#
#######################################
sub compile_fmb{
    my($host,$DEST_DIR)=@_;
    $RET=0;
$FUNCNAME=(caller(0))[3];
#split out filename.
my @fmbs= map{basename $_,""}@main::fmbs;


#frmcmp.sh module=$I module_type=FORM userid=reports/reports@bsupg8 compile_all=yes batch=no > $f_log
$f_log="frmcmp.log";

$CMD=<<CMD;
echo '
#set -x
cd $DEST_DIR
echo current dir \${PWD}
for I in @fmbs; do
#echo \${I}
#eval  echo "frmcmp.sh module=\${I} module_type=FORM userid=$BA_SERVERS{$ENV}->[2] compile_all=yes batch=no 2>&1 | tee -a $f_log"
frmcmp.sh module=\${I} module_type=FORM userid=$BA_SERVERS{$ENV}->[2] compile_all=yes batch=no 2>&1 | tee -a $f_log
done
' | ssh $host bash
CMD

writelog "DEBUG cmd = $CMD";

$ENV{CMD}=$CMD;
#excecute command. Output re-directed to us
open (SSH,"-|","$ENV{CMD}") or die "Can not open SSH";
while (<SSH>){print}
close SSH;

$RET=$?>>8;

    if ($RET ne 0){
        writelog "$FUNCNAME FAILURE $RET"
        }
    else {
        writelog "$FUNCNAME SUCCESS"
    }

return $RET; 
}


#######################################
# main
#######################################

usage($USAGE) unless @ARGV;

initlog ($LOG);

writelog "Input: $ENV,
    $ST_LABEL,
    $LABEL_DIR,
    $STARTEAM_USER ";

die "\$ENV=$ENV not defined " unless (exists $BA_SERVERS{$ENV});

writelog (DEBUG,"Get \$ORACLE_HOME at $BA_SERVERS{$ENV}->[0]");

$CMD="ssh $BA_SERVERS{$ENV}->[0] 'echo \$ORACLE_HOME' 2>/dev/null";

writelog "DEBUG $CMD";

$REM_ORACLE_HOME=`$CMD` or warn "ERROR get remote \$ORACLE_HOME";

chomp $REM_ORACLE_HOME;

writelog "DEBUG DEST_DIR=",$DEST_DIR="${REM_ORACLE_HOME}/$BA_SERVERS{$ENV}->[1]";

if(get_label ($ST_LABEL,$LABEL_DIR,$STARTEAM_USER)){
    writelog ("ERROR Error after get_label\n");
    die "Error occured";
}

writelog ("INFO starting copy of fmb");

@fmbs=();

#create list of files
find(
    # sub{push @fmbs,$_ if(-f $_)},
    { wanted => sub{push @fmbs,$File::Find::name if(-f $_)},
      bydepth => 1},
     "${LABEL_DIR}/ALL_FMB"
   );

if (cp_fmb($ENV,$DEST_DIR) ) {
    writelog ("ERROR Error after cp_fmb");
   die "Error occured";
}

if (compile_fmb($BA_SERVERS{$ENV}->[0],$DEST_DIR) ) {
    writelog ("ERROR Error after compile_fmb($ENV,$DEST_DIR)");
    die "Error occured";
}

closelog;
exit $RET;

