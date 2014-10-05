#!/usr/bin/perl
#
use Carp;  
use warnings;
use File::Basename;


#carp "This is a warning!";  
#croak "This is an error!";  #like die: print and exit
#confess "So long!";  #print message, stack and exit 

$DEBUG=0;
sub writelog (@){

    if(defined $log){
        print $log @_, "\n";
    }
    else {
        print @_, "\n";
    }
}

sub init(){

    usage() unless @ARGV;
    if( $ARGV[0] ne 'debug'){
        open($log,'>>',"$0.log") or warn "cann't create $0.log";
    }
    else
    {
        shift @ARGV; #remove "debug"
        $DEBUG=1;
    }
     
    writelog localtime()." $0 started ";
}

sub usage (){

$msg=<<MSG;

Usage:
$0 - search for differences between directories. Run 'dircmp' at a background


MSG

print $msg;

exit 0;
}


#####################################################################
# MAIN
#####################################################################


$|=1;

init();

#foreach (`ls -tr $ARGV[0]`){
#chomp;
#push @dirs,$_;
#}

#opendir(DIR, $ARGV[0]) or die "Can not open input directory $ARGV[0] : $!";

#$dirname  = dirname($ARGV[0])."/";
$dirname  = $ARGV[0]."/";
@dirs=map{chomp;$dirname.$_} `ls -tr $ARGV[0]`;
#@dirs=map{$dirname.$_} ( grep {!/^\.{1,2}/} readdir (DIR));

foreach $dir(@dirs){
    print $dir,"\n";
}

@vers=($dirs[0]); #direcories contain changes

for($i=1; $i<@dirs;$i++){
    print "compare $dirs[$i] to $dirs[$i-1] \n";

    if(`dircmp -s $dirs[$i] $dirs[$i-1] `){
        print "$dirs[$i] is different from $dirs[$i-1] \n";
        push @vers,"$dirs[$i]";
    }
    
}


open LOG,'>',"$ARGV[1]" or warn "Can not open $ARGV[1]:$!";
foreach $dir(@vers){
    print LOG $dir,"\n";
}

#close DIR;
