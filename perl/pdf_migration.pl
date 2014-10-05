#!/usr/bin/perl

#############################################
# <pdf_migration.pl> - copy files from $SOURCE to $DEST according to list from stdin. Part of KV
# support process
# Developed by <Vlad Bronfman> at <160612>
# Comments:
# Dependencies:
# In way to check
# select * from bill_images
#select  from  where customer_id='5840066'
#select distinct CUSTCODE from customer_all where customer_id in (select distinct customer_id  from bill_images)
#
#############################################

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use File::Path;
use File::Find;

#use lib "D:/Develop/Perl/File-Copy-Recursive-0.38";
#use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=0;

$DEST='\\\\Classtore\\bill_images$\\C';
$SOURCE='\\\\claraapp\\images2011$';


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
$0 - copy files from $SOURCE to $DEST according to list from stdin. Part of KV
support process.

Usage:
 $0 < <inputfile>
 where
  inputfile - is a file contains list of fullpath's of pdf. 
 
For ex.
 $0 < inputfile.txt

END

    Partner::Init::usage ($str);
}


#######################################
# main
#######################################

main::usage($str) unless @ARGV;

initlog ($LOG);

writelog ("Started");

writelog (DEBUG,"debug message");

print "dest=$DEST, source=$SOURCE\n";

#while(<DATA>){
while(<>){
    next if ($_=~/^$/);
    chomp;
    
  #  print;
    #$_=~s%\Q($SOURCE)\\([a-zA-Z1-9]*)\\.*\E%"$DEST\\$2"%eg;

#\\claraapp\images2011$\ - $SOURCE
#20120507 -$1
#\0018\188175135.pdf - $2
    $_=~s|\Q$SOURCE\E\\(\d+)\\(.*)|"$DEST\\$1"|eg;
    $source="$SOURCE\\$1\\$2";
    print "source=$source destination $_\\$2\n";
    ;
    unless (-d dirname "$_\\$2"){
        next unless mkpath (dirname "$_\\$2");
    }
    copy($source,"$_\\$2") or warn "ERROR copy $source, $_\\$2: $? $!";
     
    if (-e "$SOURCE\\$1\\RESOURCES" ){#&& !-e "$DEST\\$1\\RESOURCES") {
        print "Create $DEST\\$1\\RESOURCES\n";
        unless(mkdir "$DEST\\$1\\RESOURCES") {warn "ERROR while create $DEST\\$1\\RESOURCES: $!"; next}
        
        find(sub{
            if(!-d $_){
            copy ("$_","$DEST\\$1\\RESOURCES") or warn "ERROR copy $_ to $DEST\\$1\\RESOURCES: $!";
            }
        }
        ,  "$SOURCE\\$1\\RESOURCES");
        
    }
}

writelog ("Finished");


closelog;
exit $RET;


__DATA__


\\claraapp\images2011$\20120425\0014\187579322.pdf

\\claraapp\images2011$\20120525\0015\189592477.pdf

\\claraapp\images2011$\20120513\0011\188635916.pdf

\\claraapp\images2011$\20120507\0014\188096539.pdf

\\claraapp\images2011$\20120607\0022\190567086.pdf

\\claraapp\images2011$\20120513\0022\188591894.pdf

\\claraapp\images2011$\20120419\0002\186637423.pdf

\\claraapp\images2011$\20120519\0002\189094802.pdf

\\claraapp\images2011$\20120501\0015\187679218.pdf

\\claraapp\images2011$\20120601\0018\190123306.pdf

\\claraapp\images2011$\20120501\0008\187610424.pdf

\\claraapp\images2011$\20120601\0011\190035876.pdf

\\claraapp\images2011$\20120501\0003\188069501.pdf

\\claraapp\images2011$\20120601\0005\190521300.pdf

\\claraapp\images2011$\20120507\0005\188088078.pdf

\\claraapp\images2011$\20120607\0013\190539774.pdf

\\claraapp\images2011$\20120507\0003\188117819.pdf

\\claraapp\images2011$\20120607\0010\190560420.pdf

\\claraapp\images2011$\20120425\0001\187175695.pdf

\\claraapp\images2011$\20120525\0002\189618044.pdf

\\claraapp\images2011$\20120425\0001\187179353.pdf

\\claraapp\images2011$\20120525\0002\189620386.pdf

\\claraapp\images2011$\20120425\0000\187159371.pdf

\\claraapp\images2011$\20120525\0002\189602352.pdf

\\claraapp\images2011$\20120513\0008\188585635.pdf

\\claraapp\images2011$\20120501\0020\187676795.pdf

\\claraapp\images2011$\20120601\0023\190111666.pdf

\\claraapp\images2011$\20120513\0016\188654987.pdf

\\claraapp\images2011$\20120419\0005\186741297.pdf

\\claraapp\images2011$\20120519\0005\189184781.pdf

\\claraapp\images2011$\20120507\0014\188155844.pdf

\\claraapp\images2011$\20120607\0022\190617533.pdf

\\claraapp\images2011$\20120425\0013\187236784.pdf

\\claraapp\images2011$\20120525\0014\189691927.pdf

\\claraapp\images2011$\20120419\0013\186758358.pdf

\\claraapp\images2011$\20120519\0013\189258097.pdf

\\claraapp\images2011$\20120425\0012\187221839.pdf

\\claraapp\images2011$\20120525\0013\189682271.pdf

\\claraapp\images2011$\20120419\0012\186716683.pdf

\\claraapp\images2011$\20120519\0013\189155251.pdf

\\claraapp\images2011$\20120501\0013\187694294.pdf

\\claraapp\images2011$\20120601\0016\190136492.pdf

\\claraapp\images2011$\20120419\0010\186742578.pdf

\\claraapp\images2011$\20120519\0011\189175778.pdf

\\claraapp\images2011$\20120507\0011\188152301.pdf

\\claraapp\images2011$\20120607\0019\190604602.pdf

\\claraapp\images2011$\20120419\0010\186732868.pdf

\\claraapp\images2011$\20120519\0011\189172819.pdf

\\claraapp\images2011$\20120513\0011\188662758.pdf

\\claraapp\images2011$\20120501\0011\187741225.pdf

\\claraapp\images2011$\20120601\0014\190156524.pdf

\\claraapp\images2011$\20120507\0010\188159592.pdf

\\claraapp\images2011$\20120607\0018\190610109.pdf

\\claraapp\images2011$\20120507\0010\188226891.pdf

\\claraapp\images2011$\20120607\0018\190688971.pdf

\\claraapp\images2011$\20120419\0009\186731617.pdf

\\claraapp\images2011$\20120519\0010\189177484.pdf

\\claraapp\images2011$\20120501\0009\187732298.pdf

\\claraapp\images2011$\20120601\0012\190179009.pdf

\\claraapp\images2011$\20120513\0009\188648978.pdf

\\claraapp\images2011$\20120425\0006\187218965.pdf

\\claraapp\images2011$\20120525\0007\189658884.pdf

\\claraapp\images2011$\20120425\0004\187227782.pdf

\\claraapp\images2011$\20120525\0005\189669470.pdf

\\claraapp\images2011$\20120501\0007\187698936.pdf

\\claraapp\images2011$\20120601\0010\190139983.pdf

\\claraapp\images2011$\20120501\0006\187755720.pdf

\\claraapp\images2011$\20120601\0009\190194944.pdf

\\claraapp\images2011$\20120501\0005\187810447.pdf

\\claraapp\images2011$\20120601\0008\190233072.pdf

\\claraapp\images2011$\20120419\0002\186741405.pdf

\\claraapp\images2011$\20120519\0003\189183633.pdf

\\claraapp\images2011$\20120513\0006\188656892.pdf

\\claraapp\images2011$\20120419\0002\186855572.pdf

\\claraapp\images2011$\20120519\0002\189289864.pdf

\\claraapp\images2011$\20120507\0003\188164042.pdf

\\claraapp\images2011$\20120607\0010\190611473.pdf

\\claraapp\images2011$\20120425\0002\187244949.pdf

\\claraapp\images2011$\20120525\0003\189701851.pdf

\\claraapp\images2011$\20120425\0002\187226268.pdf

\\claraapp\images2011$\20120525\0003\189660830.pdf

\\claraapp\images2011$\20120425\0001\187205415.pdf

\\claraapp\images2011$\20120525\0002\189645481.pdf

\\claraapp\images2011$\20120419\0000\186754993.pdf

\\claraapp\images2011$\20120519\0001\189209960.pdf

\\claraapp\images2011$\20120501\0001\187695554.pdf

\\claraapp\images2011$\20120601\0002\190140182.pdf

\\claraapp\images2011$\20120507\0001\188154319.pdf

\\claraapp\images2011$\20120607\0007\190611848.pdf

\\claraapp\images2011$\20120513\0001\188662648.pdf

\\claraapp\images2011$\20120507\0000\188164131.pdf

\\claraapp\images2011$\20120607\0006\190605187.pdf

\\claraapp\images2011$\20120425\0024\187271273.pdf

\\claraapp\images2011$\20120525\0000\189682512.pdf

\\claraapp\images2011$\20120425\0024\187247044.pdf

\\claraapp\images2011$\20120525\0000\189679762.pdf

\\claraapp\images2011$\20120501\0024\187707693.pdf

\\claraapp\images2011$\20120601\0001\190152774.pdf

\\claraapp\images2011$\20120507\0000\188169311.pdf

\\claraapp\images2011$\20120607\0006\190624036.pdf

\\claraapp\images2011$\20120425\0023\187201317.pdf

\\claraapp\images2011$\20120525\0024\189653611.pdf

\\claraapp\images2011$\20120507\0020\188150994.pdf

\\claraapp\images2011$\20120607\0003\190605352.pdf

\\claraapp\images2011$\20120507\0018\188175135.pdf

\\claraapp\images2011$\20120607\0000\190625139.pdf

\\claraapp\images2011$\20120501\0021\187745327.pdf

\\claraapp\images2011$\20120601\0023\190178178.pdf

\\claraapp\images2011$\20120501\0020\187713301.pdf

\\claraapp\images2011$\20120601\0023\190167774.pdf

\\claraapp\images2011$\20120501\0020\187703372.pdf

\\claraapp\images2011$\20120601\0023\190141969.pdf

\\claraapp\images2011$\20120425\0019\187226510.pdf

\\claraapp\images2011$\20120525\0021\189666022.pdf

\\claraapp\images2011$\20120513\0021\188683122.pdf

\\claraapp\images2011$\20120513\0021\188653752.pdf

\\claraapp\images2011$\20120425\0019\187209811.pdf

\\claraapp\images2011$\20120525\0020\189664632.pdf

\\claraapp\images2011$\20120513\0021\188657845.pdf

\\claraapp\images2011$\20120513\0021\188669941.pdf

\\claraapp\images2011$\20120507\0018\188149412.pdf

\\claraapp\images2011$\20120607\0000\190602476.pdf

\\claraapp\images2011$\20120507\0018\188150247.pdf

\\claraapp\images2011$\20120607\0000\190600183.pdf

\\claraapp\images2011$\20120501\0020\187728035.pdf

\\claraapp\images2011$\20120601\0023\190179227.pdf

\\claraapp\images2011$\20120513\0020\188655643.pdf

\\claraapp\images2011$\20120513\0020\188661932.pdf

\\claraapp\images2011$\20120507\0018\188147671.pdf

\\claraapp\images2011$\20120607\0000\190604610.pdf

\\claraapp\images2011$\20120419\0019\186733742.pdf

\\claraapp\images2011$\20120519\0020\189173353.pdf

\\claraapp\images2011$\20120419\0019\186734486.pdf

\\claraapp\images2011$\20120519\0020\189195061.pdf

\\claraapp\images2011$\20120419\0019\186785451.pdf

\\claraapp\images2011$\20120519\0019\189230793.pdf

\\claraapp\images2011$\20120513\0019\188715357.pdf

\\claraapp\images2011$\20120513\0019\188634084.pdf

\\claraapp\images2011$\20120513\0019\188644747.pdf

\\claraapp\images2011$\20120419\0018\186732277.pdf

\\claraapp\images2011$\20120519\0019\189182415.pdf

\\claraapp\images2011$\20120419\0018\186792552.pdf

\\claraapp\images2011$\20120519\0019\189225397.pdf

\\claraapp\images2011$\20120501\0020\187700627.pdf

\\claraapp\images2011$\20120601\0022\190138472.pdf

\\claraapp\images2011$\20120419\0018\186736113.pdf

\\claraapp\images2011$\20120519\0018\189169073.pdf

\\claraapp\images2011$\20120501\0020\187697222.pdf

\\claraapp\images2011$\20120601\0022\190134410.pdf

\\claraapp\images2011$\20120501\0019\187696044.pdf

\\claraapp\images2011$\20120601\0022\190135001.pdf

\\claraapp\images2011$\20120513\0019\188717367.pdf

\\claraapp\images2011$\20120513\0019\188640743.pdf

\\claraapp\images2011$\20120501\0019\187696416.pdf

\\claraapp\images2011$\20120601\0021\190135093.pdf

 

