#!/usr/bin/perl
#
use Carp;
use strict;
use warnings;
use File::Basename;


#carp "This is a warning!";  
#croak "This is an error!";  #like die: print and exit
#confess "So long!";  #print message, stack and exit 

my $DEBUG=0;
sub writelog (@){

    if(defined $::log){
        print $::log @_, "\n";
    }
    else {
        print @_, "\n";
    }
}

sub init(){

    usage() unless @ARGV;
    if($ARGV[0] ne 'debug'){
        open($::log,'>>',"$0.log") or warn "cann't create $0.log";
    }
    else 
    {
        shift @ARGV; #remove "debug"
        $DEBUG=1;
    }
           
    writelog localtime()." $0 started ";
    
}

sub usage (){

my $msg=<<MSG;
$0 - collects accounts from file by given names list

Usage:
$0 <file_of_names> <file_of_accounts> [output_file]
\tfile_of_names - contains list of names 
\tfile_of_accounts - list of accounts and names in form <account> <first name> <second name>
\toutput_file - file contains result of precedure. If ommitted - stdout
Example:
$0 names.txt accounts.txt accounts


MSG

print $msg;

exit 0;
}

sub find_match(){
    
    use Tie::File;
        
    my @accounts;
    tie @accounts, 'Tie::File', $::accounts or die "Cann't tie $::accounts";
    die " vers array is empty  " unless(@accounts);
    my %accounts=();
    
    foreach (@accounts){
    
        my($account, $name)=split(/ /,$_,2);
        $accounts{$name}=$account; 
    }

    open(NAMES,'<',"$::names") or die "Cann't open $::names: $!";
    
    if ($::out){
        open(STDOUT,'>',"$::out") or die "Cann't open $::out: $!";    
    }
    
    
    while(<NAMES>){
    chomp;
        if ($accounts{$_}){
           
           writelog ("$accounts{$_} $_ ");
                # all finished
    }}
        untie @accounts;
        close NAMES;
        #close OUT;

}


#####################################################################
# MAIN
#####################################################################

$|=1;

init();
local($main::names,$main::accounts,$main::out)=@ARGV;

find_match();



    
__END__
