#!/usr/bin/perl

#############################################
# <script name> - Monitor the status of Product line
# and send notification
#
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################


use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;


use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=1;
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


#######################################
# usage() - <description>
#
#######################################
sub usage
{
    $str=<<END;
$0 - send formatted BUILD report to e-mail recepients with files of errors attached.
Divides a whole error-file into subfiles respectively.

Usage:
 $0 <logfile>
 where 
 logfile - fullpath to file contains statuses of deployment. Along with logfile supposed to be
            stored same-named file with extension ".err"
For ex.
  perl -I /home/test_user/perl/lib $0 Build_20130205_105644_26102.log 

END

    Partner::Init::usage ($str);
}


#######################################
# AUTOLOAD() - prevents propgram disasster in case of
# non-existent subprogram called
#
#######################################
sub AUTOLOAD {
use Carp;
croak "Function $AUTOLOAD not defined!";
#confess;
#warn "Function $AUTOLOAD not defined!";
    
}

#######################################
# create_output() - creates body of mail
#
#######################################
sub create_output{
 use Template;
 
 
 #my(%hash)=@_;
 my $out_html=\$body;
 
# some useful options (see below for full list)
my $config = {
    INCLUDE_PATH => './templates',  # or list ref
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 1,               # cleanup whitespace
  #  PRE_PROCESS  => 'header',        # prefix each template
    EVAL_PERL    => 1,               # evaluate Perl code blocks
};
 
# create Template object
my $template = Template->new($config,$out_html);
 
# define template variables for replacement
my $vars = {
    var1  => $build_num,
    var2  => $LOGS,
    mycode => sub { ($name)=fileparse(@_); return $name },
    var4  => \&code,
    var5  => $object,
};
 
# specify input filename, or file handle, text reference, etc.
my $input = 'BuildLog.tt';
 
# process input template, substituting variables
$template->process($input, $vars, $out_html)
    || die $template->error();
#my()=@ARGV;
   
}

#######################################
# send_mail() - sends mail by call to echo $OUT | sendmail -t
# Receives as input an array of file names 
#######################################

sub send_mail(;@)
{
    $RES=0;
    my@files=@_; #sql file has been deployed

use MIME::QuotedPrint;
use MIME::Base64;

my $mailprog = '/usr/sbin/sendmail';
#my (@address_list) = ('vlad.bronfman@orange.co.il','_Shay.Rozenbaum@orange.co.il','kerena@orange.co.il');
$address_list = "'vlad.bronfman@orange.co.il' '_Shay.Rozenbaum@orange.co.il' 'kerena@orange.co.il'";
my $from_address = 'test_user@it4tst3';
my $from_name = 'test_user';
my $subject = "BUILD LOG $build_num";

my $boundary = '=== This is the boundary between parts of the message. ===';
$MAILPART_BODY='===TEXT BOUNDARY===';

#Prepare output file
create_output();

#Create an content of e-mail per recepient.
 foreach $email_address (@address_list) {
    open (MAIL,"|$mailprog -t") or die "Cann't find sendmail:$?";

    writelog "Formating email message...\n";
    print MAIL "To: $email_address\n";
    print MAIL "From: $from_address ($from_name)\n";
    print MAIL "Subject: $subject\n";
    
    print MAIL "MIME-Version: 1.0\n";
    print MAIL "Content-Type: multipart/mixed;boundary=\"$boundary\"\n\n";
    print MAIL "--$boundary\n";
    
#print MAIL "Content-Type: multipart/alternative; boundary=\"$MAILPART_BODY\"\n\n";
#print MAIL "Content-Type: multipart/parallel; boundary=\"$MAILPART_BODY\"\n\n";
#print MAIL  "--$MAILPART_BODY\n";

    print MAIL "Content-type:text/html; charset=UTF-8\n";

   # print MAIL "Content-Disposition: inline\n";
#insert body of mail - actually a mail text
    
    print MAIL "$body";
    
    #print MAIL "--$MAILPART_BODY--\n";
  
    foreach $file (@files){
	
#	print MAIL "Content-Type: text/plain; charset=\"iso-8859-1\"\n";
#print MAIL "Content-Type: text/plain; \n";
 	#print MAIL "Content-Transfer-Encoding: quoted-printable\n\n";

##prepare files to be attacehed
 
    writelog(DEBUG,"file=$file");
    open (FILE, $file) or warn "can't open $file:$!";
    {
        binmode FILE;
        undef $/;
       # $attachment = encode_base64(<FILE>); #in case of non-test files
       $attachment = (<FILE>);
        
        #writelog (DEBUG,$attachment);
        close (FILE);
    }
    print MAIL "--$boundary\n";
#	#print MAIL "Content-Type: application/octet-stream; name=\"$attachmentFILE\"\n";
    print MAIL "Content-Location: CID:somethingatelse ; this header is disregarded\n";
print MAIL "Content-ID: <attach-$file>\n";

    #print MAIL "Content-Transfer-Encoding: base64\n";
    print MAIL "Content-Type: application/text; name=\"$file\"\n";
    print MAIL "Content-Disposition: attachment; filename=\"$file\"\n\n";
    print MAIL "$attachment\n\n";
 	
 }
    
 #finalize a mail body
 print MAIL "--$boundary--\n";
    writelog "Sending email message...";
    close (MAIL);
}
 
  return $RES;  
}

#######################################
# process_err() - creates body of mail
# Receives name of log file and fullpath to
#######################################
sub process_err($$){
    
    my($name,$path)=@_;
    #global
        my%ERRS=();
        my @errs=();
        my @files=(); #result

#open file of deployment error.
    open(BUILD_ERR,"<","$path/$name") or die "Cann't open $path/$name: $!";
    
    {
        local $/=undef; #get by topics. 
        
        @errs=split (/FILE 	       : /,<BUILD_ERR>); #split by by topics
    
        shift @errs; #remove first strings of file
    }
#Creates sub-files of errors       
    foreach (@errs){
        /^(.*)\n/;
        my($name)=fileparse($1,".sql");
        $name.=".txt";
        unless (open(OUT,">",$name) ){warn "Cann't open $1: $!\n"; next}
        print OUT;
        close OUT;
        push @files,$name;
        
    }
   
    close (BUILD_ERR);
    return @files
}

#######################################
# main
#######################################

main::usage($str) unless @ARGV;

initlog ($LOG);

writelog ("Started");
my($log )=@ARGV;

#Get filename - common for log and err files
($name,$path,$suffix) = fileparse($log,".log",".err");

open(BUILD_LOG,"<",$log) or die "Cann't open $log: $!";

#separated block in purpose to prevent influence of $/ manipulation
{
    local $/=undef; #get by topics. 

    @logs=split (/[--]+/,<BUILD_LOG>); #split by ---------
    
#get BUILD properties
$build_num=shift @logs;

    %LOGS=();
    map {
        /.*: (.*\.(trg|sql)).*STATUS.*: (\w*)/sg;
       # /STATUS.*: (.*)/;
      $LOGS->{$1}=$3; #create a hash of statuses. keys - fullpaths
      
    }@logs;  
}

#Achieve build number
$build_num=~/.*( BUILD.*).*/;
$build_num=$1;


#Prepare files of errors
#process_err("$name.err",$path) if (-f "$path//$name.err");
@files=process_err("$name.err",$path) if ("$path//$name.err");

send_mail(@files);

close(BUILD_LOG);

writelog ("Finished");

closelog;

exit $RET;

