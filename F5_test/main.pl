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

my $LOG=(-d "$ENV{PWD}/LOG")?"$ENV{PWD}/LOG/${0}_$$.log":"${0}_$$.log";
my $DEBUG=(defined($ENV{DEBUG}))?$ENV{DEBUG}:0;

#set up $DEBUG option and rid out the '-debug' from input
no strict;
map{ $main::DEBUG=1 if(/-debug\b/i && splice(@ARGV,$i,1) );$i++; } @ARGV;
use strict;
#test_file extensions
my $TEST_EXT=".test";

#just in way to keep it simple. should be replaced by regular module
#die "Error load functions: $@ $!" unless (defined (do "functions.pl" ));
#!!!commented for debug only
#do "functions.pl";

#######################################
# main
#######################################

my $RET=0;
#coolect input
#read_conf($CONF_FILE);
my @jobs=();


# Allocation values for variables
my( $progName, #program to run 
    @files2chk, # list of folders to start test within
   )=get_args();

initlog ($LOG);
writelog ("Started");

#unless (-x $progName){print_report(TST_PRG_FAILED) && exit 1 }

#Launch in loop Job->cmd for everyone of Job object
@jobs=launch_test_loop( (all_files2chk($progName,\@files2chk)));

print_report(@jobs);

writelog ("Finished");

closelog;

exit $main::RET;

###################################################################
# temporarely - for debug only!!!
# should be moved back to functions.pl


#############################################
# <script name> - Monitor the status of Product line
# and send notification
# Functions module
# just in way to keep it simple. should be replaced by regular module
#
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################
use lib "../perl/lib";
use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;

use XML::Simple;
use XML::Parser;
use threads;
use feature qw{say};
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
}


#######################################
# usage() - <description>
#
#######################################
sub usage
{
   my $str=<<END;
$0 - <description>

Usage:
 $0 <parameteres> <-debug> 
 where
    
 
For ex.
 $0 

END

    Partner::Init::usage ($str);
}


sub AUTOLOAD {
use Carp;
croak "Function $AutoLoader::AUTOLOAD  not defined!";
#confess;
#warn "Function $AUTOLOAD not defined!";
    
}



#######################################
# get_args() - in this particular case
# just instead of my(...)=@ARGV
# plus tests @ARGV is empty
#######################################
sub get_args(;@){

    my $FUNCNAME=(caller(0))[3];
    
    main::usage unless @ARGV;
    
    #in case array of references passed in
    #${$_[0]}="value";
        
    return @ARGV;
}

#######################################
# print_report() - in this particular case
# finction receives as a parameter array of Job oblects keep
# overall details of testing process
# I usually exploit Templates, for this test I'll
# allow myself a simpleminded solution.
#  *Summary
# overal number of tests 
# number of tests are succeeded
# number of tests are failed: reasons, *** discrepancy between input and output files
    
sub print_report(;@){
    my $FUNCNAME=(caller(0))[3];
     my @jobs=@_;
     
    for my $job (@jobs){
        say join ' ', $FUNCNAME,$job->{path}, $job->{status}, $job->{cmd} ;
    }
    
    my $total_tests=@jobs;
    my $succeed = 0;
    my $failed = 0;
    
    map {$failed++ if ($_->{status}) } @jobs; #success is 0
    $succeed=$total_tests - $failed;
    my$report=<<END;
    
    REPORT
    
    Total number of tests is
    
    # Summary
    # overal number of tests $total_tests
    # number of tests are succeeded $succeed
    # number of tests are failed: $failed
    reasons, *** discrepancy between input and output files
    
END

print $report;
    
}

#######################################
# all_files2chk - distinct names of folders gets
# list of files by mask and return whole list of files to check
#######################################
sub all_files2chk {
    use File::Spec;
    
    my$progName=shift;
    my $ref_list=shift;
    
    foreach my $in (@$ref_list) {
        unless (-e $in){
            push @jobs,Job->new(cmd=>$progName,
                        path=>$in,        
                        status=>FILE_NOT_FOUND);
            next;
        }
        
        if(-d $in) { #if input is a directory 
            my $cwd = File::Spec->curdir();
            chdir $in;
            my $files_found=0;

# glob over the directory           
            for(<*.in>){
                writelog("DEBUG",$_);
                $files_found++; #in purpose to check existance of files within the folder
                #checks if apropriate test file exists.
                my ($file,$dir,$sufx)=fileparse($_,".in");
                my $testfile = File::Spec->catfile($in,$file.$TEST_EXT);

#add object
                push @jobs,Job->new(cmd=>$progName,
                                    path=>File::Spec->catfile($in,$_), #could be a more sophisticated but it's 12 PM now
                                    testfile => $testfile,
                                    status=>((-e $testfile)?undef:NO_TEST_FILE),
                        );
            }
            
            chdir $cwd;
            #in case of none in files in the folder select it as FAILED
            unless ($files_found){
                push @jobs,Job->new(cmd=>$progName,
                                    path=>$in,
                                    status=>FOLDER_EMPTY, #could be a more sophisticated but is 12 PM now
                        );
            }
        }
        #if a regular file
        else{
            my ($file,$dir,$sufx)=fileparse($in,".in");
            my $testfile = File::Spec->catfile($dir,$file.$TEST_EXT);
            
            push @jobs, Job->new(cmd=>$progName,
                        path=>$in,
                        testfile => $testfile,
                        status=>((-e $testfile)?undef:NO_TEST_FILE),
                        );
        }
    }
    
    return @jobs;
}

#######################################
# launch_test_loop() - major loop
#######################################
sub launch_test_loop(;@){

    my $FUNCNAME=(caller(0))[3];
#temporary for debug
#my@jobs=map { (defined ($_->{status}))?$_ :(run_test($_))}@_;

#!!!review
# a regular threads pull should be implemented   
    
    #!!!review Add queue for params
    my @threads = map {threads->create(\&run_test, $_ ) } @_;
    my @jobs;
    push  @jobs,$_->join for @threads;    
    
    return @jobs;
}


#######################################
# run_test() - perform test 
#######################################
sub run_test {
    my $job=shift;
    writelog ("DEBUG", "\$job=",ref $job);
    #print Dumper $job;
    my $FUNCNAME=(caller(0))[3];
    
    say ('Thread started:', );
    
#for threaded version    
    return $job if( defined ($job->{status}));
#end of for threaded version

    $job->{'status'}=SUCCESS;

#sorry, pretty straightforward     
    if (open(my $out,"-|","$job->{cmd} \"$job->{path}\"") &&
        open(TEST,"<","$job->{testfile}") ){
            for(<$out>){
                ++$job->{total_lines};
                if ((my $str=readline (TEST)) ne $_)
                        {$job->{status}=FAILED;
                         push $job->{wrong_line}, $job->{total_lines}}
            }
        close $out;  
        close TEST;       
    }
    else {
        $job->{status}=TST_PRG_FAILED; #failed to open test file
    }
    return $job
}

#######################################
#  check_res - check result
#######################################
#sub check_res {
#  use File::Compare;
#  
#  #my $job->{status}=(compare("$tst", "$job->{testfile}"))?SUCCESS:FAILED; #doesn't work out for me
#  
#    
#}







