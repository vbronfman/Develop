#!/usr/bin/perl

#############################################
# <script name> - <description>
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use File::Find;
use Tie::File;
use Proc::Reliable;

#Install my_handler() as the handler for the normal-signals:
#use sigtrap 'handler', \&sig_handler, 'normal-signals';
use sigtrap 'handler'=>\&sig_handler, qw(ALRM normal-signals);

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=0;
#######################################
# functions
#######################################

#######################################
# sig_handler() - catch $SIG signal
#  
#sigtrap - Perl pragma to enable simple signal handling
#use sigtrap 'handler' => \&my_handler, 'normal-signals';
#######################################
sub sig_handler
{
    $sig=shift;
    print STDERR "Signal $sig received!!!\n";
    warn "caught $SIG{INT}";
    exit 1;
      
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


#######################################
# main
#######################################

main::usage($str) unless @ARGV;
my($file)=@ARGV;
initlog ($LOG);

tie @array, 'Tie::File', $file or die "Cann't open $file";

#compiling barepoper.fmb
$i=0;
for ($i=0; $i< $#array; $i++){
    #Form not created
    $array[$i]=~/compiling (.*)\.fmb/;
#create hash for any *fmb 
    if ($1)
    {
        $file=$1;
        $j=$i;
        #${FILES}->{$file}->{STATUS}="UNKNOWN";
        until ($array[$j] =~/Form not created/ || $array[$j]=~/Created form file /){
        
            if($array[$j]=~/Compiling .* (\w+).../){
            unless($array[$j+1]=~/No compilation errors/ ){
               # print $array[$j+1], "\n";
                ${FILES}->{$file}->{$1}=$array[$j+1];
            }
            }
            $j++;
            next
            
        }
        $i=$j;
        
        if($array[$j] =~/Form not created/ ){
            #${FILES}->{$file}->{STATUS}="FAILED";
            print "$file FAILED\n";
            $hashRef=${FILES}->{$file};
            foreach $err (values %$hashRef){
                print $err,"\n";
            }
        }
        elsif ($array[$j]=~/Created form file /){
 #          ${FILES}->{$file}->{STATUS}= "OK";
       #    print "$file OK\n\n";
           print "\n";
        }
    }
        
        
}
    


untie @array;            # all finished


writelog ("Started");


alarm 5;

writelog (DEBUG,"debug message");

writelog ("Finished");


closelog;
exit $RET;

