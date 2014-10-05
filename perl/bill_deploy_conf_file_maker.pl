######
# Billing version deployement configuration file maker
#
# Developed by V.Bronfman (by DBI connect example from
# http://www.perl.com/pub/1999/10/DBI.html)
#
# 
##

#use DBI;
#
##$dbname = "dbi:Sybase:server=YourDBHost;database=YourTable";
#$dbname = "dbi:Oracle:vantst3";
#$dbuser = "reports";
#$dbpass = "reports";
#
#my $dbh = DBI->connect($dbname,$dbuser,$dbpass,{PrintError => 0});
#if (!$dbh) { die "Unable for connect to server: $DBI::errstr\n" }
#
#my $query = "Your SQL query here";
#my $sth = $dbh->prepare($query);
#$sth->execute;
#if ($DBI::errstr) { print "$DBI::errstr\n" }
#while (@row = $sth->fetchrow_array) { print join(',',@row)."\n" }
#$sth->finish;

use DBI;
use DBD::Oracle;
use Partner::Init;
use File::Basename;
use utf8;

%TST1=(
        BLNCPROD => [
                     "BLNCTST1",
                    {RPE=>"sysadm"}, #in case the password is differ
                    {GUH=>"sysadm"}, #in case the password is differ
                    ],
                    
    #    BLNCPROD => "BLNCTST1",
        BSCS_REP => "BSCSTST1",
        BSCSPROD => ["BSCSTST1",
                    {INSTALMENTS=>"instal"},
                    {VMD=>SYSADM},
                    {RPE=>SYSADM},
                    {SPECTRA=>"SPECTRAPRD"},
                    {PROVISIONING=>"PROV"},
                    ],
        STAT => ["STATTST1",
                 {info_invoice=>"heshbonit"},
                 {BGH_PARTNER=>"bgh"}
                 ],
        BH => "BHTST1",
        RTXPROD => ["RTXTST1",
                    {sysadm=>"UNKNOWN"}
                    ],
        VANTIVE => [
                    "VANTST1",
                    {swb=>"qtip"} #in case the password is differ
                    ],
        SIEBPROD => [
                    "SIEBTST1",
                    {SIEBEL=>"espre01"} #in case the password is differ
                    ],

        IFBLPRD => "IFTST1",
    );

#aka TrainC    
    %TRAIN3=(
        BSCS_REP => "BSTRAIN3",
        BSCSPROD => "BSTRAIN3",
        VANTIVE => "VANTRAN3",
        BLNCPROD => "BLNCTRN3",
        IFBLPRD  => "GENTRN",
    );
#aka TrainB   
    %TRAIN2=(
        BSCS_REP => "BSTRAIN2",
        BSCSPROD =>
        [
         "BSTRAIN2",
        {INSTALMENTS=>"instal"},
        ],
        VANTIVE => "VANTRAN2",
        BLNCPROD => "BLNCTRN2",
        IFBLPRD  => "GENTRN", 
    );
    
    %TST3=(
        BLNCPROD => "BLNCTST3",
        BSCS_REP => "BSCSTST3",
        BSCSPROD => "BSCSTST3",
        STAT => "STATTST3",
        BH => "BHTST3",
        RTXPROD => "RTXTST3",
        VANTIVE => "VANTST3",
        IFBLPRD => "IFTST3",
    );

##############################################################
# get_by_label () - get records from DB. I case the DBname entry
# exists in appropriate hash - replace by it and write down into ouput file
##############################################################
sub get_by_label{
    
#dbi:Oracle:host=$orachehost:sid=$oraclesid",
#$dbh = DBI->connect("dbi:Oracle:dbname", "username", "passwd", {PrintError => 1, RaiseError => 0, AutoCommit => 1,})
$dbh = DBI->connect("dbi:Oracle:$DB", $USER, $USER, {PrintError => 1, RaiseError => 0, AutoCommit => 1,})
            or die "Couldn't connect to database: " . DBI->errstr;
            #$dbh = DBI->connect("dbi:Oracle:host=billdoc, SID=".$DIB, $USER, $USER, {PrintError => 1, RaiseError => 0, AutoCommit => 1,})
            #or die "Couldn't connect to database: " . DBI->errstr;

#
#$sql_request=<<SQL;
##----prepare file for billing version script SYSADM@BSCSDOC
#select DISTINCT a.default_username||\'/\'||a.default_username||\'@\'||a.default_db||\' \'|| b.filename||\' UNKNOWN\'
#,a.label_name,b.label_seq,b.seq
# from install_labels a ,install_files b
#where a.seq = b.label_seq
#AND  LABEL_NAME  in (?)
#and username is null
#union
#select DISTINCT B.username||\'/\'||B.username||\'@\'||B.db||\' \'|| b.filename||\' UNKNOWN\'
#,a.label_name,b.label_seq,b.seq
# from install_labels a ,install_files b
#where a.seq = b.label_seq
#AND LABEL_NAME in (?)
#and username is not null
#order by label_seq,seq
#SQL

#$sql_request=<<SQL;
#select DISTINCT SCHEMA||\'/\'||SCHEMA||\'@\'||DB||\' \'|| SCRIPT_NAME||\' UNKNOWN\' from tiful.billing_patcher@bscsdoc where LABEL_NAME in (?) and LAST_RUN_STATUS='SUCCESS'
#SQL
$sql_request=<<SQL;
select DISTINCT SCHEMA||\';\'||DB||\';\'||SCRIPT_NAME from tiful.billing_patcher@bscsdoc where LABEL_NAME in (?) and LAST_RUN_STATUS='SUCCESS' 
                                                                                                                                      
SQL
           
# I've decided to launch LABELs one by one in purpose to optimize SQL request for multiply calls
my $sth = $dbh->prepare($sql_request)
        or die "Couldn't prepare statement: " . $dbh->errstr;

writelog (DEBUG,$sql_request);

foreach $LABEL (@LABELS) {
    print OUTFILE (qq{######## Label $LABEL ########\n});
    #$sth->execute($LABEL,$LABEL); #$LABEL twiced in call because '?' appears in request twice
    $sth->execute($LABEL);
    $ref = $sth->fetchall_arrayref;
    my$i=0;
    do{
        #@data = $sth->fetchrow_array();
      
        
        if ($sth->rows == 0) {
            $ERR= "#ERROR!!! No files matched $LABEL.\n ";
            print $ERR;
            print OUTFILE $ERR;
            #return 1
            next;
        }
        
        writelog (DEBUG, join('----',@data));
         #unless ($str=$data[0]){
         #   print "Ohh, no data";next 
         #}
         
        $str=$ref->[$i]->[0];
#change DB entry for an appropriate name by environment         
#If exixsts entry of dbname in appropriate hash replace by it a current, overwise - do nothing
        
#      $str=~s%\E(.*\@)(\S+)( .*)\Q%${1}.((exists $ENV->{$2})?$ENV->{$2}:${2}).${3}%ei;

#$str=~m%\E(.*)(\/.*\@)(\S+)( .*)\Q%;
($SCHEMA,$DB,$file)=split(';',$str);
$filename=basename $file;#$str=~m%\E(.*)(\/.*\@)(\S+).* (\/.*)\Q%;

$SCHEMA=uc $SCHEMA;
$PASS=$SCHEMA;
$HASH_KEY=uc $DB;
if ( ref ($ENV->{$HASH_KEY}) ne 'ARRAY')
{
        #$str=~s%\E(.*\@)(\S+)( .*)\Q%${1}.$ENV->{$2}.${3}%ei;
        $DB=$ENV->{$HASH_KEY};
}
else {
    $DB=$ENV->{$HASH_KEY}[0];
    #$str="${1}$ENV->{$HASH_KEY}[1]\@$ENV->{$HASH_KEY}[0]${4}";
    for (my$i=1; $i<=$#{$ENV->{$HASH_KEY}};$i++){
        next unless( ($ENV->{$HASH_KEY}[$i])->{$SCHEMA});
            $PASS=($ENV->{$HASH_KEY}[$i])->{$SCHEMA};
        
    }
    }
    
      $str="$SCHEMA/$PASS\@$DB;$filename;UNKNOWN";
        writelog (DEBUG, $str);
#in case  DB entry exists in a corresponding %ENV hash - print into output file
        print OUTFILE (${str}."\n") if (exists $ENV->{$HASH_KEY});
        
        $i++;
    }
    while ($i < $sth->rows);
    $sth->finish;
}
         
$dbh->disconnect;

return 0;    
}

##############################################################
# usage () - print usage info
##############################################################

sub usage(){
    
    $msg=<<MSG;
    Prepare configuration file for billing version deployment.
    
Usage:
    $0 <ENV> <USER> <DB> [<PASSWD>] <OUTFILE> <LABEL1> <LABEL2> [ <LABEL3> ... ]
where
ENV - environment. Defined environments is: TRN1,TRN3,TrainB,TrainC
USER,PASSWD,$DB - connection data to the DB contains info about versions deployed in Production.
\t PASSWD assigned as USER
OUTFILE - configuration file. Contain data in form <DB_CONNECTION_STRING> <SQL_file> <STATUS>
\t If OUTFILE exists will appended by new records.

LABEL1... - list of LABELs
    
Example:
   $0 tst3 SYSADM BSCSDOC bill_ver_tst3.txt "MAILCOM_30042012" "core_billing_02052012" \
 "BRIT_02_05_2012" "VAS-IFBL-2_20120422_update"
    
MSG
print($msg);
exit 1
}

#######################################
# main
#######################################

use constant DEBUG=>1;

usage unless (@ARGV);

initlog("${0}.log");

local($ENV,$USER,$DB,$OUTFILE, @LABELS)=@ARGV;
$ENV=uc($ENV);

die  "$ENV is not defined!\n"  unless (%$ENV);

writelog (DEBUG,"Deployment on $ENV. Connect to $USER\/$USER\@$DB in order to retrive LABELs: ".join(',',@LABELS));

open (OUTFILE,">>",$OUTFILE) or die "Cann't open $OUTFILE: $?";
#select OUTFILE; $| = 1;
#non-zero indicate an error
if (get_by_label()){
    writelog "ERROR get_by_label failed: $?";
}

closelog;

close OUTFILE;
close STDOUT;


__DATA__

%TST1=(
        BLNCPROD => [
                     "BLNCTST1",
                    {rpe=>"sysadm"}, #in case the password is differ
                    {guh=>"sysadm"}, #in case the password is differ
                    ],
                    
    #    BLNCPROD => "BLNCTST1",
        BSCS_REP => "BSCSTST1",
        BSCSPROD => ["BSCSTST1",
                    {INSTALMENTS=>"instal"},
                    {VMD=>SYSADM},
                    {RPE=>SYSADM},
                    {SPECTRA=>"SPECTRAPRD"}
                    ],
        STAT => ["STATTST1",
                 {info_invoice=>"heshbonit"},
                 {BGH_PARTNER=>"bgh"}
                 ],
        BH => "BHTST1",
        RTXPROD => ["RTXTST1",
                    {sysadm=>"UNKNOWN"}
                    ],
        VANTIVE => [
                    "VANTST1",
                    {swb=>"qtip"} #in case the password is differ
                    ],
        SIEBPROD => [
                    "SIEBTST1",
                    {SIEBEL=>"espre01"} #in case the password is differ
                    ],

        IFBLPRD => "IFTST1",
    );

#aka TrainC    
    %TRAIN3=(
        BSCS_REP => "BSTRAIN3",
        BSCSPROD => "BSTRAIN3",
        VANTIVE => "VANTRAN3",
        BLNCPROD => "BLNCTRN3",
        IFBLPRD  => "GENTRN",
    );
#aka TrainB   
    %TRAIN2=(
        BSCS_REP => "BSTRAIN2",
        BSCSPROD => "BSTRAIN2",
        VANTIVE => "VANTRAN2",
        BLNCPROD => "BLNCTRN2",
        IFBLPRD  => "GENTRN", 
    );
    
    %TST3=(
        BLNCPROD => "BLNCTST3",
        BSCS_REP => "BSCSTST3",
        BSCSPROD => "BSCSTST3",
        STAT => "STATTST3",
        BH => "BHTST3",
        RTXPROD => "RTXTST3",
        VANTIVE => "VANTST3",
        IFBLPRD => "IFTST3",
    );