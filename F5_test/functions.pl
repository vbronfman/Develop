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
# print_usage() - <description>
#
#######################################
sub print_usage
{
   my $str=<<END;
$0 - checks list of resources by given test utility 

Usage:
 $0 <test_program> <list of fullpaths> [/debug] 
 where
    test_program - the fullpath to program performs test
	list - full pathes of files or folders to test;
	
	THe program suppose for every input file <*.in> a corresponding <*.out>
	Program compare the output that produced by test_program with file.in as an input.
 
For ex.
 $0 /home/user/test.pl /home/user/tests/file1.in /home/user/tests1 

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
    
    main::print_usage unless @ARGV;
    
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
     $state={};
	 
	say '*'x30,"\n","\t\tREPORT"; 
    for my $job (@jobs){
			print '-'x20 , "\n";

	say "Input file: ",$job->{path};
	
	#if defined $state->{$job->{status}}=$jobs;
	# switch grabbed from http://stackoverflow.com/questions/844616/obtain-a-switch-case-behaviour-in-perl-5
	my $switch = {
		FAILED() => sub { say "TEST failed"; say "Lines are different: ", join ",", @{$job->{wrong_line}}  },
		NO_TEST_FILE() => sub { say "NO_TEST_FILE";  },
		SUCCESS() => sub { say "SUCCESS";  },
		FILE_NOT_FOUND() => sub { say "FILE_NOT_FOUND "; },
		FOLDER_EMPTY() => sub { say "supplied folder is empty "; },
		TST_PRG_FAILED() => sub { say "test program fafilure "; },
		RUN() => sub { say "test RUN - actually wrong status "; },
		'default' => sub { say "unrecognized"; }
	};
	$switch->{$job->{status}} ? $switch->{$job->{status}}->() : $switch->{'default'}->();
		}
		
        
    #print values $status->{'SUCCEED'};
    
    my $total_tests=@jobs;
    my $succeed = 0;
    my $failed = 0;
    
    map {$failed++ if ($_->{status}) } @jobs; #success is 0
    $succeed=$total_tests - $failed;
    
	
	my$report=<<END;
    
    # Summary
    # overal number of tests $total_tests
    # number of tests are succeeded $succeed
    # number of tests are failed: $failed
    
    
END

print $report;
    
}

#######################################
# all_files2chk - distinct names of folders gets
# list of files by mask and return whole list of files to check
#######################################
sub all_files2chk {
    use File::Spec;
    #test_file extensions
my $TEST_EXT=".test";

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
				say "Check $testfile";

#add object
                push @jobs,Job->new(cmd=>$progName,
                                    path=>File::Spec->catfile($in,$_), #could be a more sophisticated but it's 12 PM now
                                    testfile => $testfile,
                                    status=>((-e "$testfile")?undef:NO_TEST_FILE),
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
                        status=>((-e "$testfile")?undef:NO_TEST_FILE),
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
   # if (open(my $out,"-|","$job->{cmd} \"$job->{path}\"") &&
   my $res=open(my $out,"-|","$job->{cmd} \"$job->{path}\"") or warn "ERROR $job->{cmd} ";
   #check if command piped
  # if (eof($out)){ close $out;; $job->{status}=TST_PRG_FAILED; return $job;}
   
   if( open(TEST,"<","$job->{testfile}") ){
            for(<$out>){
                ++$job->{total_lines};
                if ((my $str=readline (TEST)) ne $_){
					$job->{status}=FAILED;
					#say "DEBUG string is $_";
                    push $job->{wrong_line}, $job->{total_lines}}
            }
        
		close $out; 
		#close returns exit code of program launched at the end of the pipe 
		my $exit = $? >> 8;
		if ($exit) {
			say "Error start program $job->{cmd} exit:($exit)";
			$job->{status}=TST_PRG_FAILED;
		}		 
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







