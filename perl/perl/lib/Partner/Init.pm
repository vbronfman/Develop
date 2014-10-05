
package Partner::Init;

use Carp;
use Getopt::Std;
use Getopt::Long;
use Config;


require Exporter;	
	@ISA = qw(Exporter);	
	@EXPORT = qw( writelog initlog closelog usage get_label); 
	@EXPORT_OK = qw(); 


###################################################
# Collect program's arguments
###################################################

%packhash=(key1=>"value1",key2=>"value2");

my %optctl = (debug => \$main::dbgmode,
		log => \$main::logfile, 
		parser => \$main::parsedby,
                conf => \$main::config,
                
	);

my %inputargs=();

sub new() {
    
    my $self = {};
    bless $self;
    return $self;
}

sub newp (@){
    
  my $self = {};
 
  ;
  initialize(@_);
    bless $self;
    return $self;  
}

sub initfunc(){
    
#my %optctl = (debug => \$dbgmode,
#		log => \$logfile, 
#		test => \$parser,
#	); 
#

    
    #&GetOptions("size=i" => \$offset); 
    eval {     &GetOptions(\%optctl, "debug!","log=s", "conf:s", "parser:s");  };

    if($@){ 
        die "Failed to get input parameteres: $@" 
    }

}

sub printargs(){
 
 print "in printargs";
   
foreach my$key (keys %optctl){
	print "$key = ", ${$optctl{$key}}; #key is reference to scalar 
}
}

sub initialize(){
#inparm-list of arguments name names
my @inparm=@_;
print "in initialize";

$ref = \"$inparm[1]";
%inputargs=($inparm[1] => \${$inparm[1]},
		log => \$logfile, 
		test => \$test,
	);

print keys %inputargs;

}


sub func2(){

print "in initfunc";

}

sub usage {
    
    print STDOUT @_;
    exit 1;
}

sub initlog(;$){
$LOG=shift;
$LOG="${0}.log" unless (defined $LOG); 

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$DATE=sprintf "%4d-%02d-%02d", $year+1900,$mon+1,$mday;
$TIME=sprintf "%02d:%02d:%02d",$hour,$min,$sec;

#rotate log in case 100Mb achivhed
if (-s $LOG > 100000000 ) {
    carp "Rolling log";

    require File::Copy or return -1;
    $rolled_file=sprintf ("%s_%02d-%02d-%4d-%02d-%02d",$LOG,$hour,$min,$year+1900,$mon+1,$mday);
    File::Copy::move($LOG,$rolled_file) or carp "Error while move $LOG into $rolled_file";
}

open(STDOUT,"| tee -a $LOG ") or print "Error initialising $LOG\n";
print "\n$DATE $TIME \t##### $0 Started ##### \n";
}

sub closelog(){
    
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$DATE=sprintf "%4d-%02d-%02d", $year+1900,$mon+1,$mday;
$TIME=sprintf "%02d:%02d:%02d\t",$hour,$min,$sec;

print "$DATE $TIME ##### $0 Finished ###### \n";

if (defined LOG ) {
    close LOG;
   }
}

sub writelog {
#sub print_msg {
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$DATE=sprintf "%4d-%02d-%02d", $year+1900,$mon+1,$mday;
$TIME=sprintf "%02d:%02d:%02d\t",$hour,$min,$sec;

#if (defined LOG ) {
#    select LOG;$|=1;
#}
  
if($_[0]=~/^DEBUG/){  
    print "$TIME ", shift, " @_\n" if($main::DEBUG);
}
else {
    print "$TIME ", @_, "\n"
}

#return unless(shift eq "DEBUG")?{print $TIME, "DEBUG ", @_, "\n"}: print $TIME,@_, "\n";
}

###############################################################
#   get_label() function
# Uses stcmd in way to checkout files from Starteam
###############################################################
sub get_label ($$$){
$RET=0;
my $FUNCNAME=(caller(0))[3];

#my$STARTEAMSERVER=$main::STARTEAMSERVER // "starteam1";
#my$STARTEAMSERVERPORT=$main::STARTEAMSERVERPORT//"49201";
#my $STARTEAM_USER= ${main::STARTEAM_USER} // $ENV{$LOGNAME};
#$ST_PASSWD= $main::STARTEAM_PASSWD // "";
#my${ST_CONNECTION_STRING}="$ST_USER/$ST_PASS\@$ST_SERVER:$ST_PORT";
#
#$STARTEAM_PROJ= $main::STARTEAM_PROJ // "BillingMigration";
#$STARTEAM_VIEW=$main::STARTEAM_VIEW // "10gba";
#${ST_LABEL}= $_[0] // "";
#$LABEL_DIR= $_[1] // "";

my$STARTEAMSERVER=$main::STARTEAMSERVER ;
my$STARTEAMSERVERPORT=$main::STARTEAMSERVERPORT;
my $STARTEAM_USER= ${main::STARTEAM_USER} ;
$ST_PASSWD= $main::STARTEAM_PASSWD ;
my${ST_CONNECTION_STRING}="$ST_USER/$ST_PASS\@$ST_SERVER:$ST_PORT";

$STARTEAM_PROJ= $main::STARTEAM_PROJ ;
$STARTEAM_VIEW=$main::STARTEAM_VIEW ;
${ST_LABEL}= $_[0];
$LABEL_DIR= $_[1] ;



#-rp directory : Override the view's working directory
#    -fp directory : Override the specified folder's working directory (full path must be supplied)
   # /CRM/vantive
#excecute command
#stcmd co -p "hkoren1:xxxx@starteam1:49201/CRM/Vantive/SRC/Database Procedures" -nologo -eol lf -o -fp /users/b50krnd/CRM -is -ts -vl "2.69.1" -x
# Has been discovered that bco doesn't work with revision label!

#CMD="bco –p “[user]/[password]@<STservername>:[port]/<PROJECT>/[VIEW]” -vb  -fp /users/b50krnd/CRM -cfgl <label_name> -is  -eol lf  "
#-dryrun
#    Don't actually check any files out, but display a list of files that would
#    be checked-out if '-dryrun' is not specified.
#-fs
#    Don't update the status (sync) record of each file after check-out.
# -x Bypass error messages

if ( $ST_PASSWD eq "" ){
        $ST_CONNECTION_STRING="${STARTEAM_USER}\@${STARTEAMSERVER}:$STARTEAMSERVERPORT";
}
else
{
        $ST_CONNECTION_STRING="${STARTEAM_USER}:${ST_PASSWD}\@${STARTEAMSERVER}:$STARTEAMSERVERPORT"
}

    
#CMD="bco –p ${ST_CONNECTION_STRING}/$STARTEAM_PROJ/$STARTEAM_VIEW -cfgl ${ST_LABEL} -fp "." -is -dryrun"

$ENV{PATH}.=";d:\\Program Files\\Borland\\StarTeam Cross-Platform Client 2009";

$STCMD=($^O eq "MSWin32")?'stcmd.exe':"stcmd";
#-ro : Set file read-only after operation
#-csf : treat folder names as case-sensitive
#-filter filter : Status filter: e.g. "CM" would apply command only to
#                     files with status "Current" or "Modified".
#                     M=Modified, C=Current, O=Out-of-Date, N=Not-in-View,
#                     I=Missing, G=Merge, U=Unknown
#-q : Suppress progress reporting
#-x : Bypass error messages
#-stop : Halt execution after first error, default is to keep running
$CMD=qq { $STCMD co -p ${ST_CONNECTION_STRING}/$STARTEAM_PROJ/$STARTEAM_VIEW -vl ${ST_LABEL} -stop -nologo -eol lf -o -fp ${LABEL_DIR} -is -fs  -ts -x -csf};
writelog "DEBUG cmd=$CMD";
    
#launch commang
    `$CMD` or warn "error execute ";
    $RET=$?>>8;

if ( $RET ne 0 ){
    writelog "$FUNCNAME FAILURE $RET $!"
}
else{
    writelog "$FUNCNAME SUCCESS"
}


return $RET;
    
}

1;

