#!/bin/env perl -I ../../perl/lib

#############################################
# <script name> - Monitor the status of Product line
# and send notification
# Main module
#
# Developed by <developer> at <date>
# Comments: So far only full pathes of input files/folders are supported
# Test is failed after every first discrepancy
# Dependencies:
# Use functions of ../perl/lib/Init/Partner.pm"
#
#############################################

use strict;
use warnings;
use threads;

use lib "../perl/lib";
use Partner::Init;
 
use File::Basename;
use File::Copy;
use Data::Dumper;

use XML::Simple;
use XML::Parser;
use sigtrap 'handler', \&sig_handler, 'normal-signals';

use Job 1.0;
use feature qw{say};

package main;

our $VERSION = '1.0';

#######################################
# Global variables
#######################################
use constant {  SUCCESS        => 0,
                WARNING        => 3,
                FAILED         => 1,
                TIMED_OUT      => 4,
                FILE_NOT_FOUND => 5,
                FOLDER_EMPTY   => 6,
                TST_PRG_FAILED => 7,
                RUN            => 8,
                NO_TEST_FILE   => 9,
            };   

my $LOG="${0}_$$.log";
my $DEBUG=(defined($ENV{DEBUG}))?$ENV{DEBUG}:0;
our $RET=0;

#set up $DEBUG option and rid out the '-debug' from input
no strict;
map{ $main::DEBUG=1 if(/-debug\b/i && splice(@ARGV,$i,1) );$i++; } @ARGV;
use strict;
#test_file extensions
my $TEST_EXT=".test";

#just in way to keep it simple. should be replaced by regular module
# for the same reason error check is omitted
 do "functions.pl";

#######################################
# main
#######################################



#coolect input
#read_conf($CONF_FILE);
#array of Job objects. Contain overall details of the launch
my @jobs=();

# Allocation values for variables
my( $progName, #program to run 
    @files2chk, # list of folders to start test within
   )=get_args();

#initlog ($LOG,1);:setting a second parameter up sends output into log file and suppresses on-screen output
initlog ($LOG); 
writelog ("Started");

#unless (-x $progName){print_report(TST_PRG_FAILED) && exit 1 }

#Launch in loop Job->cmd for everyone of Job object
@jobs=launch_test_loop( (all_files2chk($progName,\@files2chk)));

print_report(@jobs);

writelog ("Finished");

closelog;

exit $RET;

