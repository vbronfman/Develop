#!/bin/perl

use File::Find;
use File::Basename;

sub func (){
    
    
    
}

#
# main
#

$host="znbillapptst1";
@dirs=qw{billtst1 rattst1 bscstst1};

#find (\&func, @dirs);

foreach $dir (@dirs){
    
    my $pid=fork;
    die "Cann't fork: $!" unless defined $pid;
    
    unless($pid){
        print "\t\\_ $$: Hello, I'm a child process\n";
        $cmd=qq{find . -type f -perm -111 -print -exec file {} \; | egrep -e ".*ELF.*executable.*" | tee find_exe_in_$dir.log};
        #exec $cmd;
    }
    else{
        print "\t\\_ $$: Hello, I'm a parent process\n";
    }
    
}

