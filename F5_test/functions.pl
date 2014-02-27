
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
# read_conf() - read in configuration by XML::Simple
# my $simple = XML::Simple->new( ); # initialize the object
# not in use in current project
#
#######################################
sub read_conf($){
    my $RET=0;
    my $FUNCNAME=(caller(0))[3];
    
    my($FILENAME)=@_;
    
    writelog "$FUNCNAME Parse by XML::Simple\n";
    
    
    my $conf = XML::Simple->new( ); # initialize the object
    #my $tree = $conf->XMLin( $FILENAME, ForceArray => [ 'products','product','environment' ] );
    my $tree = $conf->XMLin( $FILENAME); # read, store document
    
    #print Dumper($tree);
    
    foreach my$prod (  keys %{$tree->{products}->{product}} ) 
    {
        print Dumper $prod;
        next if($tree->{products}->{product}->{$prod}->{state} eq "disabled");
    
        foreach my$key ( $tree->{products}->{product}->{$prod}){
                   
            my$ref=$key->{environment}; #must be defined as global in next version
            
            print $key->{cmd}->{content}, "\n";

# Collects definiton of environment                    
            foreach my$ENVkey (@$ref){
                next if ($ENVkey->{state} eq "disabled");
                my $job=Job->new;
                $job->{prod}=$prod;
                
                unless (exists $key->{ITsystem} ){
                    $job->{ITsystem}=$prod;
                }
                else {
                    $job->{ITsystem}=$key->{ITsystem};
                }
                           
                $job->{env}=$ENVkey->{env};
                $job->{timeout}=$key->{cmd}->{timeout};
                $job->{_db}=$ENVkey->{db};
                
                local $main::DB=$ENVkey->{db}; #value to replace for in string from config file
                local $ENV=$ENVkey->{env};

# Variables substitution 
                chomp '"'.$key->{cmd}->{content}.'"';
                $job->{_cmd}=eval('"'.$key->{cmd}->{content}.'"'); #replace and assign the value
                
                #push @main::TO_RUN, \$job;
                
  #Handle of a case of more than one account per product 
                if((ref $ENVkey->{account}) eq "ARRAY"){
                    foreach my $str (@{$ENVkey->{account}}){
                     print "$str\n";
                     $job->{_account}=$str;
                     push @main::TO_RUN, $job;
                    }
                    #print $ENV->{account}->[0], "\n";
                    #print $ENV->{account}->[1], "\n";    
                    
                }else{
                    print $ENVkey->{account}, "\n";
                    $job->{_account}=$ENVkey->{account};
                    push @main::TO_RUN, $job;
                }              
            
            }       
        }
    }
    
    @main::TO_RUN=sort {print;
                  #${$a}->{env} cmp ${$b}->{env}} @TO_RUN;
                  ${a}->{env} cmp ${b}->{env}} @main::TO_RUN;
    
    #print Dumper (@main::TO_RUN);
    
    #Notification properties, kind of global
        $ref=$tree->{mail}->{sendto}->{recipient}; #pointer into list of recepients
        $template_dir=$tree->{mail}->{template_dir};
        $template_file=$tree->{mail}->{out_html};
        $input_template=$tree->{mail}->{input_template}; 
        $out_html=$tree->{mail}->{out_html};
        
        $subject_file=$tree->{mail}->{subject_file};
    
    return $RET;
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
sub print_report(;@){
    my $FUNCNAME=(caller(0))[3];
     my @jobs=@_;
     
    for my $job (@jobs){
        say join ' ', $FUNCNAME,$job->{path}, $job->{status}, $job->{cmd} ;
    }
    # Summary
    # overal number of tests 
    # number of tests are succeeded
    # number of tests are failed: reasons, *** discrepancy between input and output files
    
}

#######################################
# all_files2chk - distinct names of folders gets
# list of files by mask and return whole list of files to check
#######################################

sub all_files2chk {
    use File::Spec;
    
    my$progName=shift;
    my $ref_list=shift;
    
    foreach $in (@$ref_list) {
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
            
            for(<*.in>){
                print;
                $files_found++;
                push @jobs,Job->new(cmd=>$progName,
                                    path=>File::Spec->catfile($in,$_), #could be a more sophisticated but it's 12 PM now
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
        #if regular file
        else{
            push @jobs, Job->new(cmd=>$progName,
                        path=>$in,
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
@jobs=map { run_test($_) unless defined $_->{status}}@_;

#!!!review
# a regular threads pull should be implemented
    
    
    ##for $job (@jobs){
    ##    #my $ref = $job->can('run');
    ##    unless ( defined (my $thr = threads->create( \&run_test,$job))){
    ##    #
    ##    }
    ##    
    ##    push @threads, $thr;
    ##}
    ##$job->{status}=$thr->join();
    ##$_->join for @threads;
    #!!!review Add queue for params
    #my @threads = map { next if defined $_->{status}
    #    threads->create(\&run_test, $_ ) } @_;
    #push @jobs,$_->join for @threads;    
    
    return @jobs;
}


#######################################
# run_test() - perform test 
#######################################
sub run_test {
    my $job=shift;
    print "\$job=",ref $job;
    #print Dumper $job;
    my $FUNCNAME=(caller(0))[3];
    
    say ('Thread started:', );
    
    $job->{'status'}=RUN;
    
    #system ($job->{cmd},$job->{path}) or return $job->{status}="FAILED";
    #my $cmd="$job->{cmd} $job->{path}";
    open(my $tst,"-|","$job->{cmd} \"$job->{path}\"") or return $job->{status}="FAILED";
    my $out=<$tst>;
    
    #print check_res ($tst, $job->{outfile});
    use File::Compare;
  
    $job->{status}= compare($tst, "$job->{outfile}");
  
    close $tst; #?
     
    return $job
}

sub check_res {
  use File::Compare;
  
  
    
}





