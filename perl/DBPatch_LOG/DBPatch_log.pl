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


use Config;

if ($Config{osname} == "MSWin32"){
    use lib "../perl/lib";
}
else
{
    use lib "/ITLAB_share/itlab/perl/lib";
}

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;
use Switch;


use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
#$LOG="${0}.log";
$DEBUG=1;

$CONFIG_FILE="config.xml";

@EXTENSIONS=qw/.trg .sql .pck .pks .pkb .prc/;


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
# usage() - <description>
#
#######################################
sub usage
{
    $str=<<END;
$0 - send formatted BUILD report to e-mail recepients along with error files attached.
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
# read_conf() - read in configuration by XML::Simple
#my $simple = XML::Simple->new( ); # initialize the object 
#
#######################################
sub read_conf($){
    
    use XML::Simple;
    
    $RET=0;
    $FUNCNAME=(caller(0))[3];
    
    my($FILENAME)=@_;
    
    exit -1 unless (-f $FILENAME);
    
    writelog "$FUNCNAME Parse by XML::Simple\n";
    
    my $conf = XML::Simple->new( ); # initialize the object
    #my $tree = $conf->XMLin( $FILENAME, ForceArray => [ 'products','product','environment' ] );
    
    
    
    my $tree = $conf->XMLin( $FILENAME); # read, store document
    
    #print Dumper($tree);
    return $tree;
}

#######################################
# on_exit() - called after signal
#
#######################################
sub on_exit{
    $RET=0;
    $FUNCNAME=(caller(0))[3];
    
    writelog "$FUNCNAME called on signal, $0 terminated";
    
    #in temporary way!!! should  elaborate
    #send_notification($main::CONF_FILE, "$0 terminated by timeout");
    
    die "Terminated\n\n";
}


#######################################
# create_output() - creates body of mail
#
#######################################
sub create_output{
 use Template;
 
 my $out_html=\$body;
 
# some useful options (see below for full list)
my $config = {
 #   INCLUDE_PATH => './templates',  # or list ref
    INCLUDE_PATH => $config_tree->{mail}->{template_dir},  # or list ref
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
my $address_list = $config_tree->{mail}->{sendto}->{recipient};

my $from_address = $config_tree->{mail}->{sender};
my $from_name = $from_address;
my $subject = "BUILD LOG $build_num";

my $boundary = '=== This is the boundary between parts of the message. ===';
$MAILPART_BODY='===TEXT BOUNDARY===';

#Prepare output file
create_output();

open my $tmp, '>', \$variable or die "Can't open variable: $!";
#print $fh "Treat this filehandle like any other\n";

    writelog "Formating email message...\n";
   # print $tmp "To: $email_address\n";
    print $tmp "From: $from_address ($from_name)\n";
    print $tmp "Subject: $subject\n";
    
    print $tmp "MIME-Version: 1.0\n";
    print $tmp "Content-Type: multipart/mixed;boundary=\"$boundary\"\n\n";
    print $tmp "--$boundary\n";
    
#print MAIL "Content-Type: multipart/alternative; boundary=\"$MAILPART_BODY\"\n\n";
#print MAIL "Content-Type: multipart/parallel; boundary=\"$MAILPART_BODY\"\n\n";
#print MAIL  "--$MAILPART_BODY\n";

    print $tmp "Content-type:text/html; charset=UTF-8\n";

   # print MAIL "Content-Disposition: inline\n";
#insert body of mail - actually a mail text
    
    print $tmp "$body";
    
    #print MAIL "--$MAILPART_BODY--\n";
  
    foreach $file (@files){
	
#	print MAIL "Content-Type: text/plain; charset=\"iso-8859-1\"\n";
#print MAIL "Content-Type: text/plain; \n";
 	#print MAIL "Content-Transfer-Encoding: quoted-printable\n\n";

##prepare files to be attacehed
    $file.='.txt';
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
    print $tmp "--$boundary\n";
#	#print MAIL "Content-Type: application/octet-stream; name=\"$attachmentFILE\"\n";
    print $tmp "Content-Location: CID:somethingatelse ; this header is disregarded\n";
    print $tmp "Content-ID: <attach-$file>\n";

    #print MAIL "Content-Transfer-Encoding: base64\n";
    print $tmp "Content-Type: application/text; name=\"$file\"\n";
    print $tmp "Content-Disposition: attachment; filename=\"$file\"\n\n";
    print $tmp "$attachment\n\n";
 }
    
 #finalize a mail body
 print $tmp "--$boundary--\n";
 
 #Create an content of e-mail per recepient.
foreach $email_address (@$address_list) {
    open (MAIL,"|$mailprog -t $email_address") or die "Cann't find sendmail:$?";
print MAIL $variable;
    writelog "Sending email message...";
    close (MAIL);
}
close $tmp;
 
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
    
        #my($name)=fileparse($1,".sql");
        #my($name,$dir,$ext)=fileparse($1,@EXTENSIONS); #should be case-insensitively
        my($name,$dir,$ext)=fileparse($1,qr/$mask/i); #should be case-insensitively
        
        unless (open(OUT,">",$name.".txt")){warn "Cann't open $1: $!\n"; next}
        print OUT;
# Shouldn't be here... Kind of ugly patch
#Check for "Warning: Package Body created with compilation errors"
# ORA-00955
#ORA-01430
@WARNINGS=qw/warning ORA-00955 ORA-01430/;
my$mask=join '|', @WARNINGS;

        #if(/(warning|ORA-00955|ORA-01430)/i){
        if(/($mask)/i){
            $LOGS->{$name}->[0]="WARNING";
            switch($1){
                case /warning/i {
                    /.*CONNECT STRING : (\S+\/\S+\@\S+)\s/;
                    $DB_CONNECT=$1;
                    #$name=~/\d+_(.*)_body/i;
                    $name=~/\d+_(.*)_\S+/i;
                    my$PACKAGE=uc $1;
                    print OUT "\n\nPackage $PACKAGE compilation errors:\n", get_warning_txt($DB_CONNECT,$PACKAGE);
                }
                
            }
        }
                
        close OUT;
        push @files,$name;
    }
   
    close (BUILD_ERR);
    return @files
}

#######################################
# get_warning_txt() - execute SQL request
# 
#######################################
sub get_warning_txt($$){
    
    my($DB,$PACKAGE)=@_;
    #for debug
    $PACKAGE='PCK_DUNN_INSTALLMENT';
    #end of for debug
    
   writelog("DEBUG  DB to connect $DB; package name $PACKAGE");
    $cmd=<<CMD;
    
sqlplus -L -s $DB <<EOF
SET PAGESIZE 200
SET LINESIZE 200
COLUMN owner HEADING 'OWNER' FORMAT A10 WRAP
COLUMN name HEADING 'NAME' 
COLUMN line HEADING 'LINE #'
COLUMN text HEADING 'TEXT' FORMAT A60 WRAP


    select owner,name,line,text from dba_errors where name = '$PACKAGE'  ---  CAPITAL
order by line;
exit;
EOF

CMD

    return `$cmd`;
    
    
}
#######################################
# main
#######################################

main::usage($str) unless @ARGV;

# initlog ($LOG);
initlog;

writelog ("Started");

my($work_dir)=dirname($0);

$config_tree=read_conf("$work_dir/$CONFIG_FILE");

my($log )=@ARGV;

#Get filename - common for log and err files
($name,$path,$suffix) = fileparse($log,".log",".err");

open(BUILD_LOG,"<",$log) or die "Cann't open $log: $!";

#separated block in purpose to prevent influence of $/ manipulation
{
    local $/=undef; #get by topics. 

    #@logs=split (/[----]+/,<BUILD_LOG>); #split by ---------
    @logs=split (/------------------------------------------/,<BUILD_LOG>); #split by ---------
    
#get BUILD properties
$build_num=shift @logs;
$mask=join '|', @EXTENSIONS;

    %LOGS=();
    map {
        #if(/.*: (.*\.(trg|sql|pck|pks|pkb|prc)).*STATUS.*: (\w*).*/sig){
        if(/.*: (.*($mask)).*STATUS.*: (\w*).*/sig){
#           my($name,$path)=fileparse($1,@EXTENSIONS); #
           my($name,$path)=fileparse($1,qr/$mask/i); #
           
           $LOGS->{$name}=[$3,$path,$2]; #create a hash of statuses. keys - fullpathes
        }
    }@logs;  
}

#Achieve build number
$build_num=~/.*( BUILD.*).*/;
$build_num=$1;

#Prepare files of errors
@files=process_err("$name.err",$path) if (-e "$path//$name.err");

send_mail(@files);

close(BUILD_LOG);

writelog ("Finished");

closelog;

exit $RET;

