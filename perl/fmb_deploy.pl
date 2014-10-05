#!/usr/bin/perl -I .

#############################################
# <script name> - Monitor the status of Product line
# and send notification
#
# Developed by <developer> at <date>
# Comments:
# Dependencies:
#
#############################################

use lib "/ITLAB_share/itlab/perl/lib";
use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;

use sigtrap 'handler', \&sig_handler, 'normal-signals';
do "Monitor/send_notification.pl";

#######################################
# Global variables
#######################################
$LOG="${0}.log";
$DEBUG=1; #0 - less debug info will printed out
$NO_MAIL=0;

$CC_HOST="ponda";
$CC_USER="ccmngr";
$CC_PROJ_AREA="~ccmngr/proj";
$FORMS_FOLDER="myforms";

$mail_body="/ITLAB_share/itlab/mail_body";
$mail_subject="/ITLAB_share/itlab/mail_subject";
$mail_recepient='InfraNonProdTeam@orange.co.il';
#$mail_recepient='vlad.bronfman@orange.co.il';

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


sub usage
{
    $str=<<END;
    $0 - Copy fmb from CC proj area into remote server and compile them by comp_fmx
    Copy files into ${ORACLE_HOME}/myforms at a remote server.
    
    Usage:
     $0 <SOURCE_FOLDER> <REMOTE_HOST> <LIST OF FILES>
     where
        SOURCE_FOLDER - path to Source folder
        REMOTE_HOST - credentials for ssh
        LIST_OF_FILES - list of fmb files 
     
    For ex.
    vmit15dev02!ccmngr:/ITLAB_share/itlab [1046]$ perl fmb_deploy.pl /home/ccmngr/proj/PM_BSS/PM_BSS_201211/forms/myforms oracle@vmbatest3 change_payment_type.fmb 
    
END
    
        Partner::Init::usage ($str);
}


sub AUTOLOAD {
    use Carp;
    croak "Function $AUTOLOAD not defined!";
    #confess;
    #warn "Function $AUTOLOAD not defined!";
        
}

sub scp {
 #copy as a list, not one by one   
    writelog ("In scp: $SOURCE\n");
    open(MAIL, ">>",$mail_body) or warn "Cannot open $mail_body" ;
    #return 1 unless chdir "$SOURCE";
    # die "cannot change dir to $SOURCE" unless chdir "$SOURCE";
    croak "cannot change dir to $SOURCE" unless chdir "$SOURCE";
    $LIST=join " ",@LIST_OF_FILES;
    
    print MAIL ("<br>############# Copy files: ########################## <br> $list_to_prt <br> \
                from $SOURCE <br> to $DEST: $rORACLE_HOME:/myforms/<br> \
                ------------------------------------------- <br> ");
    
    `ls @LIST_OF_FILES`;
    print MAIL "**********************************<br>\
    Pay attention one or more files not found!!!<br>\
    **********************************<br>" if($?>>8); 
    chomp ($rORACLE_HOME=`ssh $DEST \'echo \${ORACLE_HOME}\'`);
    writelog " DEBUG \$rORACLE_HOME=$rORACLE_HOME";
    
    $cmd="scp -p $LIST $DEST:$rORACLE_HOME/$FORMS_FOLDER"; #in case of TST3
    writelog ("DEBUG In ${$FUNCNAME=(caller(0))[3];}: $cmd\n");
    
#open STDERR, ">&STDOUT"     or die "Can't dup STDOUT: $!";
#select STDERR; $| = 1;  # make unbuffered
#select STDOUT; $| = 1;  # make unbuffered 
    $res= `$cmd 2>&1`;
    
#close STDERR;
    if ($?>>8){
        writelog ("DEBUG $res");
        $res=~s|\012|<br>|;
        print MAIL ("FAILURE:<br> $res<br>");
    }
    else
    {
        print MAIL ("Copied successfuly<br>");        
    }
    close MAIL;
    return $res;   
}

sub comp_fmx {
  
    select;
    $|=1;
    
    open(MAIL, ">>",$mail_body) or warn "Can not open $mail_body:$?\n";
#open(MAIL, ">&STDOUT")or warn "Can not open $mail_body:$?\n";
    print MAIL ( "<br>############# FMB compilation #####################<br>");  

    foreach my$FILE(@LIST_OF_FILES){
        print MAIL ( " -------------------------------------------<br>");                              
        print MAIL "Compiling $FILE<br>";
        my $cmd="\${ORACLE_HOME}/bin/comp_fmx \${ORACLE_HOME}/myforms/".$FILE;
     #   my $cmd="/ba/app01/oracle/product/OraHome_1/bin/comp_fmx /ba/app01/oracle/product/OraHome_1/myforms/$FILE";
        writelog "GOING to run $cmd\n";
        #print MAIL "run $cmd<br>";
        
        my $res= qx /ssh $DEST \'echo \${ORACLE_HOME};$cmd\'/;
       
        $RES{$FILE}=$res; #collects results
        #Created form file /ba/app01/oracle/product/OraHome_1/myforms/hamsa.fmx
        
        $res=~/\012(.*)$/; $result=$1;
        writelog "DEBUG result $res";
        $res=~s|\n|<br>|g;
        
      #  print MAIL ($res."= $result =============================================<br>");
        print MAIL ( " $result <br> ");                              
    }
    
    print MAIL " </body>\n</html>";
    close MAIL;
}

sub create_mail_header(){
    open(MAIL, ">",$mail_body) or return 1;
    $list_to_prt=join ("<br>",@LIST_OF_FILES);
    $msg=<<MSG;
 <html>
 <head>
    <h1> INFRA Non-PROD Team (IT-Lab) </h1>
 </head>
  <body>
    
MSG
    print MAIL $msg;
    close MAIL;
    
}

sub create_mail(){
    
    use Template;
    $template_dir='./templates';
    $input_template="$template_dir/fmb_mail_template.tt";
    
#$Template::Stash::PRIVATE = undef;
# some useful options (see below for full list)
    my $config = {
    #    INCLUDE_PATH => './templates',  # or list ref
        INCLUDE_PATH => $template_dir,  # or list ref
        INTERPOLATE  => 1,               # expand "$var" in plain text
        POST_CHOMP   => 1,               # cleanup whitespace
        #PRE_PROCESS  => 'header',        # prefix each template
        EVAL_PERL    => 1,               # evaluate Perl code blocks
    };
     
    # create Template object
    my $template = Template->new($config) || die "$Template::ERROR\n";
    
    print Dumper $template;
   
    # define template variables for replacement
    my $vars = {
        var1  => "j;lk;lK", #not in use
        var2  => \%RES,
        var3  => \@{LIST_OF_FILES},
        var4  => \&code, #just for example
        var5  => \$object,
    };

    # process input template, substituting variables
    $template->process($input_template, $vars, $mail_body)
    || die $template->error();
}

#######################################
# main
#######################################

main::usage($str) unless @ARGV;

($SOURCE,$DEST,@LIST_OF_FILES)=@ARGV;
#use Template;
# 
## some useful options (see below for full list)
#my $config = {
#    INCLUDE_PATH => '/search/path',  # or list ref
#    INTERPOLATE  => 1,               # expand "$var" in plain text
#    POST_CHOMP   => 1,               # cleanup whitespace
#    PRE_PROCESS  => 'header',        # prefix each template
#    EVAL_PERL    => 1,               # evaluate Perl code blocks
#};
# 
## create Template object
#my $template = Template->new($config);
# 
## define template variables for replacement
#my $vars = {
#    var1  => $value,
#    var2  => \%hash,
#    var3  => \@list,
#    var4  => \&code,
#    var5  => $object,
#};
# 
## specify input filename, or file handle, text reference, etc.
#my $input = 'myfile.html';
# 
## process input template, substituting variables
#$template->process($input, $vars)
#    || die $template->error();
##my()=@ARGV;
initlog ($LOG);

writelog ("Started");

create_mail_header();

scp($LIST,$SOURCE,$DEST);


writelog "FAILED comp_fmx" unless comp_fmx();

#$mail_format, $SubjectFileName, $address_to_send,@mail_body
#create_mail();
send_mail($mail_body,$mail_subject,$mail_recepient, @LIST_OF_FILES) unless ($NO_MAIL);

writelog ("Finished");

closelog;
exit $RET;

