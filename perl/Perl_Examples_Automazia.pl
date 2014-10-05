

=commented
use SOAP::Lite;


 my $soap = SOAP::Lite 
   ->uri('http://10.236.33.141/wsHodaot/Hodaot.asmx')
  ->proxy('http://10.236.33.141/wsHodaot/Hodaot.asmx');
  $res="";
my $result = $soap->getResult("sdsd", \$res);


=cut
use SOAP::Lite ( +trace => all, maptype => {} );
#use SOAP::Lite ( maptype => {} );


sub ParseXML_in(;$$$);


$xml_in = "msg_input_new.xml";
$out_xml="out.xml";
$MSG_MESSAGE_ID="850";
$MSG_OWNER_ID="212";
$xml=ParseXML_in($MSG_OWNER_ID, $MSG_MESSAGE_ID,$xml_in); #create xml for shaul


print $xml."\n\n\n\n";




my $soap = SOAP::Lite
   #-> uri('http://10.236.33.141/wsHodaot/')
   -> uri('http://tempuri.org/')
    -> on_action( sub { join '/', 'http://tempuri.org', $_[1] } )
    -> proxy('http://ntticpt0/hodaotWS/Hodaot.asmx');


my $header = SOAP::Header->name(MyHeader => {
     MyName => "MyName"
})->uri('http://10.236.33.141/wsHodaot/')->prefix('');
#     })->uri('http://tempuri.org/')->prefix('');


#print $soap->TestMe($header)->result;


$string="strOutput"; 
$outPut=$string;


my @params = (
   $header,
   SOAP::Data->name(sInputXML => $xml), 
   SOAP::Data->name(sOutputXML => $outPut) 
);


#my $method = SOAP::Data->name('getRequest')
  # ->attr({xmlns => 'http://10.236.33.141/wsHodaot/'});


#print $soap->call($method => @params)->result;
   $result= $soap->getRequest(@params); #XML-string from WEBService


#
unless ($result->fault) {
print " \n\n\n getRequestResponse/sOutputXML".($outPut= $result->valueof('//getRequestResponse/sOutputXML'))."\n\n\n\n"; #get values by XPath
print " \n\nsOutputXML\n $outPut \n\n\n";
print "\n\n".$result->valueof('//getRequestResponse/sOutputXML/MSG_DESTINATION NAME')."\n\n";








#    print "\n\n\n\n".$result->result()."\n\n\n\n";
open (outXML, ">$out_xml");print outXML ($result->result()); close outXML;
    
  } else {
    print join ', ', 
      $result->faultcode, 
      $result->faultstring;
  }
=com
my $method = SOAP::Data->name('TestMe')
    ->attr({xmlns => 'http://10.236.33.141/'});


my @params = ( SOAP::Data->name(x1 => 3), 
               SOAP::Data->name(x2 => 4) );
 
print $soap->call($method => @params)->result;  


  
exit;


=cut


###################################
=pod
Error check must be added!!!


=cut
###################################
sub ParseXML_in(;$$$){


use strict;
use FileHandle;
use XML::DOM;


my $retcode=0;
my ($MSG_OWNER,$MSG_MESSAGE,$file)=@_;
#my $file = 'msg_input.xml';




my $parser = XML::DOM::Parser->new();
my $doc = $parser->parsefile ($file); 
#if($main::DEBUG)
{print $doc->toString  }


foreach my $node ($doc->getElementsByTagName ('*')){ #get all tags in file, returned list of Elements
    if ($node->getTagName eq 'MSG_OWNER') {$node -> setAttribute('ID',$MSG_OWNER);}
    elsif ($node->getTagName eq 'MSG_MESSAGE') {$node -> setAttribute('ID',$MSG_MESSAGE)};
}
 
# Print doc file
$doc->printToFile ("out.xml");
#if($main::DEBUG)
{print ($retcode = $doc->toString)  }


 # Avoid memory leaks - cleanup circular references for garbage collection
$doc->dispose;
return $retcode;
}




==========================================


Unicenter.pl example


#!/usr/bin/perl
###################################################
=pod
Model name : Unicenter.pl


Description:
    Send Notifications to responsible groups of users.
Start by unicenter.Receive as input MSG_OWNER_ID and MSG_MESSAGE_ID. By static template msg_input.xml build XML and send it
to Announcement System (developed by Shaul  - at this time call is not implemented). Get back xml file (msg_output.xml is default)
and parse it for the purpose of getting notifications properties of present  MSG_OWNER_ID and MSG_MESSAGE_ID's:
-type of notifications : fax, sms, e-mail
-groups of users
-message text
-subject text


Usage: Unicenter.pl [-n node name] [-p PROJECT_NAME] -o <MSG_OWNER_ID> -m <MSG_MESSAGE_ID> [-l LOG_file] [/debug]


input parameters:
        -n node name
        -p PROJECT_NAME
        -o MSG_OWNER_ID
        -l LOG-file. If not defined and not '/debug' - file name is "unicenter.log" by default
        -m MSG_MESSAGE_ID
        -f free text (for debug)
        - debug - redirect output to display instead LOG-file.
        
Must be installed :
    \tXML::DOM
    SOAP::Lite
    CS_Functions
    otinienv


Known restrictions and bugs:
    - hebrew in XML is not allowed
    - thereof UNICENTER's restrictions some path  must be allocated as hard-build (d:/ot_sr/sys/v1.0/utl)
    - In "כללי"( 'common') case a message text received from Shaul may be too long for separate SMS so we need to suppress transferring of 'text' parameter to SendSms     
    Development History:    
  Name          version  Date  Description and Purpose of Modification      #
#  ----------------------------------------------------------------------------- #
Bronfman    1.0.0  10.06.05    Development
Bronfman    2.0.0  10.10.05    Development, Connect2Shaul(
Bronfman    2.1.0  10.10.05   Relese
Bronfman    2.1.1  10.10.05   Repaired bug in case of empty string from Shaul: list of users


#############################################################################
=cut
use lib "./CS_Functions";
use lib "d:/OT_SR/SYS/V1.0/UTL";
use CS_Functions;


use Carp;
#use AnyDBM_File;
#require DBI_File;
#require DBD::ODBC;
#use CS_Functions;


use utf8;
    use Encode;
$VERSION="2.1.1"; #version 
$DEBUG=0;


  
# functions declaration
sub arguments_parser(\%);
sub Usage();
sub ParseXML_in(;$$$);
sub GetUsersByGroups($\$);
sub RecurceGetXMLNodes($\@);
sub SendNotification($$$);


use constant EMAIL=>1;
use constant FAX=>2;
use constant SMS=>3;
use constant "\x{5db}\x{5dc}\x{5dc}\x{5d9}"=>4; #כללי.


#MAIN
my $retcode=0;


$ref=\%ARGHASH; #hold argument-value pairs
 arguments_parser(%{$ref});
    
    my $MSG_OWNER_ID= int($ARGHASH{"-o"}) ;
    my $MSG_MESSAGE_ID = int($ARGHASH{"-m"});
    #global variable from $PROJECT_NAME
    my $project = (defined $ARGHASH{-p}) ? $ARGHASH{-p} : "Unknown_project";
    my $free_text = $ARGHASH{"-f"};


#if not defined 'debug' in command line output is redirected into file. File name is defined by 'l' parametr and 'Unicenter.log'  by default
    unless($DEBUG==1){
        #$log_file=$ARGHASH{'-l'} if (defined ($ARGHASH{'-l'})) ;
        $log_file=(defined ($ARGHASH{'-l'})) ? $ARGHASH{'-l'} : "Unicenter.log";
        #open (LOG,">>$log_file") or warn "can not open $log_file\n";
        #select (LOG);
        open(STDOUT, '>>', $log_file) || die "Can't redirect stdout";
        open(STDERR, ">&STDOUT")     || die "Can't dup stdout";


        select(STDERR); $| = 1;     # make unbuffered
        select(STDOUT); $| = 1;     # make unbuffered
    #$^=1;
    }
 
my $notification_ref = \%NOTIFICATIONS_HASH;
#for debug only
  
print "\n\n============================================================\n",scalar localtime;;
print "\nMSG_OWNER_ID= $MSG_OWNER_ID MSG_MESSAGE_ID = $MSG_MESSAGE_ID project = $project\n free_text=$free_text \n";


# When script started by application the current dir is assigned according it , for ex. d:\TNG for UNICENTER's case, so we need
#  some method for working files location determination. Well, the right way is about using  INI-files, but directly declaration is
#    rather good too.
#chdir "d:/ot_sr/sys/v1.0/utl" unless (defined $ENV{"DEVELOP_ENVIRONMENT"} ) ;


#  $notification_ref  - is referense on hash in which values will be stored : keynames - $notification_type,and values
#array of subject,$text, $ref_users. $ref_users - referense to list of usernames.
    exit 1 if GetRecipientsList($MSG_OWNER_ID, $MSG_MESSAGE_ID,$notification_ref) ; #must be designed in right way


#if have not received from shaul set as כללי. Should not occurs in ordinary use 
unless( keys (%NOTIFICATIONS_HASH) ) {
    print "\n HASHREF is empty! Default values will be used \n";
    $subject="Error $project";
    $text="MSG_OWNER_ID= $MSG_OWNER_ID MSG_MESSAGE_ID = $MSG_MESSAGE_ID  free_text=$free_text";
    $default_group="LADPC\\Mabat";
    $key = "\x{5db}\x{5dc}\x{5dc}\x{5d9}";
    GetUsersByGroups($default_group,$ref_users);
    @addresses = (@addresses, split(",",$ref_users));
    
    $NOTIFICATIONS_HASH{$key} = [$subject,$text, @addresses];
    
}
#############
    
while(my ($notification_type,$params)=each(%NOTIFICATIONS_HASH)) {
#if ($DEBUG){
    print "\n$notification_type: ";
    foreach (@$params) {
    $octets = encode("cp1255", $_) ; 
     print "$octets "; }
    print "\n";
#}
    SendNotification($project,$notification_type,$params);
}
    
unless($DEBUG==1){   close (STDOUT);  close(STDERR);}
exit $retcode;
#__END__


#===================================================================
#functions definitions
#===================================================================


###################################
=pod
cmd_parser.pl Command line parser, check parameteres
Parameteres is single character predicated with '-'. Support non-delimitered argunebts, like -cparameter.
Build hash of parameteres.As function receive reference on HASH and called as:
cmd_parser(\%)  cmd_parser(%{$HASHREF}) then $HASHREF=\%HASH;
In future must be applicated as module


In main function
$ref=\%ARGHASH;#hold argument-value pairs
arguments_parser(%{$ref});
=cut
###################################
sub arguments_parser(\%){


$hashref = $_[0];


if (grep (/^[-\/]\?/, @ARGV)) {  # check if defined 
Usage();
exit 1;
}


if($DEBUG=grep (/^[\/-]debug\b/, @ARGV)){ # check if defined 
@ARGV=grep (!/^.debug\b/, @ARGV) ; #clean from @ARGV
}
while (@ARGV){
    $parm=shift @ARGV;
    #$count++;
=debug
    $parm=~ s/(-.\B)//; #substitute
=cut
    $parm=~ s/^(-.)//; #substitute
    #$found = $1;print "fond=$found parm=$parm\n";
=debug    
    if($1) {push @ARRAY,lc $1,$parm; } #$1 found value essentialy 
    else {push @ARRAY,$parm;}
=cut
    if($1){ $$hashref{$1}=join(' ',$$hashref{$1},$parm)} #$1 found value essentialy 


}#while


=debug
%$hashref=@ARRAY;
=cut
}




###################################
=pod




=cut
###################################


sub Usage() {
    my$string=<<__LINE_TO_PRINT;
$0 ver. $VERSION
Send Notifications to responsible groups of users 
Start by unicenter.Receive MSG_OWNER_ID and MSG_MESSAGE_ID. Exchange data by XMLs. Perl version - at least 5.8.6!
Usage: Unicenter.pl [-n node name] [-p PROJECT_NAME] -o <MSG_OWNER_ID> -m <MSG_MESSAGE_ID> [-l LOG_file] [/debug]


input parameters:
    -n node name
    -p PROJECT_NAME
    -l LOG-file. If not defined and not '/debug' - file name is "unicenter.log" by default
    -o MSG_OWNER_ID
    -m MSG_MESSAGE_ID
    -f free text - add to subject of messages
    - debug - redirect output to display instead LOG-file.
        
Must be installed :
    XML::DOM
    SOAP::Lite
    CS_Functions
    otinienv


Known restrictions and bugs:
    - thereof UNICENTER's restrictions some path  must be allocated as hard-build (d:/ot_sr/sys/v1.0/utl)
    - the group of SMS recipients defined as "mabat" only - for  compatibility with exist Unicenter's structure.
    - In "כללי"( 'common') case a message text received from Shaul may be too long for separate SMS
        so we need to suppress transferring of  'text' parameter to SendSms()
    


__LINE_TO_PRINT
print $string;
}


###################################
=pod
Error check must be added!!!


=cut
###################################
sub ParseXML_in(;$$$){


use strict;
use FileHandle;
use XML::DOM;


my $retcode=0;
my ($MSG_OWNER,$MSG_MESSAGE,$file)=@_;
#my $file = 'msg_input.xml';
print "\nIn ParseXML_in:\n MSG_OWNER = $MSG_OWNER,MSG_MESSAGE = $MSG_MESSAGE\n";


my $parser = XML::DOM::Parser->new();
my $doc = $parser->parsefile ($file); 
#if($main::DEBUG)
{print "DEBUG: ",$doc->toString  }
#my $parent = $doc->getDocumentElement;
#setAttributeNode (attr)


foreach my $node ($doc->getElementsByTagName ('*')){ #get all tags in file, returned list of Elements
    if ($node->getTagName eq 'MSG_OWNER') #MSG_OWNER
        { $node -> setAttribute('ID',$MSG_OWNER);}
    elsif ($node->getTagName eq 'MSG_MESSAGE') {$node -> setAttribute('ID',$MSG_MESSAGE)};
}


# Print doc file
$doc->printToFile ($file);
#if($main::DEBUG)
{print "\nDEBUG: ".$doc->toString  };


 # Avoid memory leaks - cleanup circular references for garbage collection
$doc->dispose;
return $retcode;
}






###################################
=pod




=cut
###################################
sub GetRecipientsList($$@){
my ($MSG_OWNER_ID, $MSG_MESSAGE_ID,$notification_ref) = @_;


my $retcode=0;
$xml_in = "msg_input_new.xml";
$xml_out = "msg_output.xml";


ParseXML_in($MSG_OWNER_ID, $MSG_MESSAGE_ID,$xml_in); #create xml for shaul


eval {Connect2Shaul($xml_in,$xml_out);};
#exit;
#after receiving xml from shaul 
return $retcode = ParseXML_out($notification_ref,$xml_out); #get xml file by name and parse it;$notification_ref referense to hash hold type of notofication,message and groups of recepients
}


###################################
=pod
ParseXML_out(\%;$$)
Get back xml file (msg_output.xml is default)
and parse it for the purpose of getting notifications properties of present  MSG_OWNER_ID and MSG_MESSAGE_ID's:
-type of notifications : fax, sms, e-mail
-groups of users
-message text
-subject text (not used in new format)
Search  pre-defined NODEs by Name "MSG_INTERFACE"


=cut
###################################
sub ParseXML_out(\%;$$){


#use strict;
use FileHandle;
use XML::DOM;


my($refNOTIFICATIONS_HASH,$file,$node_name)=@_;
my $retcode=0;
#my $ref2Send_struct = [$subj,$text,@addresses];
#my $file = 'msg_output.xml';


#unless(defined $node_name) {$node_name = 'MSG_INTERFACE';}
unless(defined $node_name) {$node_name = 'MSG_DESTINATION';}


my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile($file);


#foreach my $node ($doc->getElementsByTagName('MSG_INTERFACE'))
my $nodes = $doc->getElementsByTagName($node_name);
my $n=$nodes -> getLength;


#my $ref2Send_struct = [$subj,$text,@addresses]; #referense on array


#my $ref2Send_struct = [$subj,$text,@addresses];
@data_ref=($subject,$text,@addresses);


for (my $i = 0; $i < $n; $i++)
{
    my $node = $nodes->item ($i);
#@data_ref=($subject,$text,@addresses);
#my @addresses= ();
#my $subject = "subj_undefined";
#my $text = "Message text";
 
if ($node->hasChildNodes) {


=commented for new XML format test    
            my @childrens = $node->getChildNodes;
            foreach my $child (@childrens) {
            RecurceGetXMLNodes($child,@data_ref);
            }
=cut


        print $text=$node->getElementsByTagName('MSG_TEXT')->item(0)->getFirstChild->getNodeValue , "\n";


        
foreach  $sub_node ($node->getElementsByTagName('MSG_GROUP'))
            {
                push(@groups,$sub_node->getAttribute('NAME'));
            }
    }


    $type_of_notification=$node->getAttribute('NAME');


#    foreach (@data_ref)  {print "send_to= $_ \n" ;};;
    
#$$refNOTIFICATIONS_HASH{$type_of_notification }= \@data_ref;
    
    #$subject = shift @data_ref;
$subject = "Error";
    #$text = shift @data_ref;
my $ref_users=\$users;
    #foreach (@data_ref){
foreach (@groups){
        $retcode =GetUsersByGroups($_,$ref_users);
        return $retcode if ($retcode); 
        @addresses = (@addresses, split(",",$ref_users));
    
    }
    
    #@addresses = @data_ref;
    ($refNOTIFICATIONS_HASH)->{$type_of_notification }= [$subject,$text,@addresses];
    $#addresses = -1;
 #print scalar ($refNOTIFICATIONS_HASH)->{$type_of_notification }->[3]; ;
} # for   


=comment
   if ( $node->getNodeType == TEXT_NODE) {
       print $node->getNodeName;
       my $text = $node->getNodeValue;
        print $text;
   }
    else { #if subtree
        foreach my $sub_node ( $node->getChildNodes) {
           
        if( $sub_node->getNodeType != TEXT_NODE){ # == XML::DOM::TEXT_NODE ){
           print "\n subnode ".$sub_node->getNodeName." ";
           my $attr= $sub_node->getAttributes;
           print my $attr_len =  $attr->getLength;


           print $attr ->item(0)->getNodeTypeName;
            print $attr ->item(0)->getName." = ";
           print $attr ->item(0)->getValue;
           
           #print $sub_node->getAttribute('NAME');
           }
            else{
                print $sub_node->getNodeName;
           $text = $sub_node->getNodeValue;
           print $text;
            }
       }
   print "\n";
}
=cut


=commented
while(my ($k,$v)=each(%$refNOTIFICATIONS_HASH)) {
    print "$k: ";
    foreach (@$v) { print "$_ " }
    print "\n";
}
=cut


 # Avoid memory leaks - cleanup circular references for garbage collection
$doc->dispose;


return $retcode;
}




###################################
=pod




=cut
###################################
sub GetUsersByGroups($\$){
my($group,$ref_users) = @_;
my $retcode=0;
$cmd="getinienv unicenter.ini GROUPS $group";
$$ref_users=`$cmd`;
 if($?) {$retcode = $?>>8 ; #success of getinienv is 0
        print "$cmd\nGetinienv error $retcode: ".`getinierr $retcode`;
 }
#print $group,$$ref_users;
return $retcode;
}






###################################
=pod




=cut
###################################
sub SendNotification($$$){
my($project,$notification_type, $params) = @_;
my $retcode = 0;


#binmode(STDOUT, ":utf8");


#$flag = utf8::is_utf8("כללי"); #\x{5db}\x{5dc}\x{5dc}\x{5d9}
$flag = utf8::valid($notification_type);


unless(index($notification_type,"\x{5db}\x{5dc}\x{5dc}\x{5d9}")) { #כללי"
    $retcode=SendEmail($project,$params);
    $retcode=SendFax($params);
# In "כללי" 'common' case a message text may be too long for separate SMS so we need to suppress transferring of $text parameter
$params->[1] = "";
 $retcode=SendSms($params);
}




if(uc($notification_type) eq "EMAIL"){
    $retcode=SendEmail($project,$params);
}
elsif (uc($notification_type) eq "FAX"){
$retcode=SendFax($params);
}
elsif (uc($notification_type) eq "SMS"){
 #   print "before SendSMS\n";
$retcode=SendSms($params);
}


return $retcode;
}


###################################
=pod




=cut
###################################
sub SendEmail($$){
    #use strict;


    use CS_Functions;
    
    my ($project,$params) = @_;
my $retcode = 0;
    my($subject,$text,@temp_array);


    @temp_array=@{$params};
  
#first and second is subject and text accordingly
    $subject = shift @temp_array;
    $host = uc (`hostname`);
    $subject = $subject ." : ".$free_text ;
    $text = shift @temp_array;


    foreach (@temp_array) {
        print "DEBUG : In SendMail : foreach(temp_array) : $_\n";
    my $mail;        
        print "Cann't get user properties for $_\n" if(GetUserProperties($_,\$mail,EMAIL));
        print "\n $mail \n" if ($DEBUG==1);
        push @receipients,$mail;
        #unless 
        }
   # $text = "error";
    
 use Encode;
    $octets = encode("cp1255", $text) ; #to Hebrew Windows encoding for Outlook 
#$success = decode("utf8", $text);
    print "\n In  SendEmail :Message text ", $octets, "\n";


    CS_Functions::SendMail($project,$subject,$octets, @receipients);


    print "\n DEBUG In  SendEmail : AFter CS_Functions::SendMail\n";
return $retcode;
}    




###################################
=pod




=cut
###################################
sub SendFax($){
    my ($subject,$text,$addresses) = @_;
my $retcode = 0;


    
return $retcode;
}


###################################
=pod
In temporary way performs call to sendsms.bat by sender.pl
At this time not check recepients list and send to "mabat" group


=cut
###################################
sub SendSms($){
 #use strict;
 use Encode;
    #use CS_Functions;
#print "Cann't change dir " unless chdir ("c:/perl"); 
    my ($params) = @_;
my $retcode = 0;
    my($subject,$text,@temp_array);


    @temp_array=@{$params};
  print $subject,$text,@temp_array;
#first and second is subject and text accordingly
    $subject = shift @temp_array;
     $subject = $subject .":".$free_text ;
    $text = shift @temp_array;


    foreach (@temp_array) {
    my $dest;
    print "\nDEBUG: SendSMS : Before GetUserProperties  -  $_\n";
        print "Cann't get user properties for $_\n" if(GetUserProperties($_,\$dest,SMS));
        print "\n $dest \n" ;#if ($DEBUG==1);
        #push @receipients,$dest;
        #unless 
        
 
    $octets = $subject. encode("cp1255", $text) ; #to Hebrew Windows encoding for Outlook 
#$success = decode("utf8", $text);
    print "\n SendSms : Message text ", $octets, "\n";


    #in temporary way!
    $group="mabat";
    ###
 if($dest=~/052/) {    $cmd = "c:/perl/cellcomsms.bat $dest \"$octets\"";}
 elsif($dest=~/050/) {    $cmd = "c:/perl/pelephone.bat $dest \"$octets\"";}
 print "DEBUG In SendSMS Command is $cmd\n";
   # $cmd = "perl c:/perl/sender.pl $group \"$octets\"";
 #  print "before sender.pl. cmd = $cmd\n";
$retcode=system $cmd ;
   $retcode = $retcode>>8;
 #  print "after sender.pl, error : $retcode\n";
   
}    
=commented 
    foreach (@temp_array) {
    my $mail;        
        print "Cann't get user properties for $_\n" if(GetUserProperties($_,\$mail,SMS));
        print "\n $mail \n" if ($DEBUG==1);
        push @receipients,$mail;
        #unless 
        }


=cut
    
return $retcode;
}


###################################
=pod




=cut
###################################
sub GetUserProperties(){#$_,$mail,MAIL
    my ($username,$dest,$notification_type) = @_;
my $retcode = 0;


if($notification_type == EMAIL){
    #in temporary way only!!!!!! Must be regular call to AD
    $$dest=$username.'@ladpc.co.il';
    
}
if($notification_type == SMS){
    #in temporary way only!!!!!! Must be regular call to AD
    $cmd="getinienv unicenter.ini PHONES $username";
    print $cmd;
$$dest=`$cmd`;
 if($?) {$retcode = $?>>8 ; #success of getinienv is 0
        print "$cmd\nGetinienv error $retcode: ".`getinierr $retcode`;
 }
    
}
return $retcode;
}
    


###################################
=pod
Connection to WebService of Shaul


=cut
###################################
sub Connect2Shaul($$){ #$xml_in,$xml_out
use SOAP::Lite (
    #+trace => all,
    maptype => {} );


my($xml_in,$out_xml) = @_;


#get proxy (address of WebService) from INI
$proxy = `getinienv unicenter.ini WebService proxy`;
if($?) {$retcode = $?>>8 ; #success of getinienv is 0
        print "$proxy\nGetinienv error $retcode: ".`getinierr $retcode`;
 }


#very ugly
open (XML_IN, $xml_in) or die "Cann't open $xml_in!!!\n";
while (<XML_IN>) {
$xml = $_;
print "\n\n XML-string from $xml_in\n".$xml, "\n\n"; 
}close XML_IN;
#end of very ugly


my $soap = SOAP::Lite
   #-> uri('http://10.236.33.141/wsHodaot/')
   -> uri('http://tempuri.org/')
    -> on_action( sub { join '/', 'http://tempuri.org', $_[1] } )
 #   -> proxy('http://10.236.33.141/wsHodaot/Hodaot.asmx');
-> proxy($proxy);


my $header = SOAP::Header->name(MyHeader => {
     MyName => "MyName"
})->uri('http://10.236.33.141/wsHodaot/')->prefix('');


#     })->uri('http://tempuri.org/')->prefix('');


#print $soap->TestMe($header)->result;


$string="strOutput"; 
$outPut=$string;


my @params = (
   $header,
   SOAP::Data->name(sInputXML => $xml), 
   SOAP::Data->name(sOutputXML => $outPut) 
);


   $result= $soap->getRequest(@params); #XML-string from WEBService


#
unless ($result->fault) {
print " \n\n getRequestResponse/sOutputXML\n".($outPut= $result->valueof('//getRequestResponse/sOutputXML'))."\n\n"; #get values by XPath




#    print "\n\n\n\n".$result->result()."\n\n\n\n";
open (outXML, '>:utf8',$out_xml)  or die "Cann't open $out_xml !!!\n\n";print outXML ($result->result()); close outXML;
    
  } else {
    print join ', ', 
      $result->faultcode, 
      $result->faultstring;
  }
}






#########################################################
# Not in use functions


###################################
=pod




=cut
###################################
sub MultiplyMessages(){


$semaphorName=CreateSemaphorName(); #according to PROJECT, etc...


GetMessagePriority();
if (!IfFirstTime() ){
    if (CheckIfMustBeEscalated())
    {
        #do something: send SMS to manager
    
    ReleaseSemaphore($semaphorName); 
    }
}
else { #first time
    my @RecipientsList;
    $RecipientsListRef = \@RecipientsListRef;
    
    CreateSemaphore($semaphorName); #Mutex?
}
}


###################################
=pod




=cut
###################################
sub RecurceGetXMLNodes ($\@) {
my ($sub_node,$rA) = @_;






return if(!defined $sub_node); #if node is not exist


my $type = $sub_node -> getNodeType;
unless ($type == TEXT_NODE) {$node_name = $sub_node->getNodeName;}
#print "\nNode_name = ".$node_name."\n";


    if($type == ELEMENT_NODE) {
        if ($sub_node->hasChildNodes) {
            my @childrens = $sub_node->getChildNodes;
            foreach my $child (@childrens) {
               # RecurceGetXMLNodes($child) if($child->getNodeType != TEXT_MODE);
                RecurceGetXMLNodes($child,@$rA);
                
            }                
        }
    




    my $attr = $sub_node->getAttributes;
    my $attr_len =  " ".$attr->getLength;


        for ($i=0;$attr_len > $i; $i++ ) {
        $attr ->item(0)->getNodeTypeName;
        $attr_name = $attr ->item($i)->getName;
        #print " ".$attr_name." = ";
        $attr_value=$attr ->item($i)->getValue;
        print " ".$attr_name." = ".$attr_value ;
        push @$rA,$attr_value; #temporary - must be real 
        
        }
   }
    elsif ( $sub_node->getNodeType == TEXT_NODE) {
        #print "In text_mode section : node_name = ".$node_name;
        if($node_name eq "MSG_CAPTION")
        {
            #print "\n getData = ".$sub_node->getData." //getData";
            $subject=$sub_node->getData;
        #    print $text;
            $node_name = "";
#(ССЫЛКА)->[номер];            
            $rA->[0]=$sub_node->getData;
            }
        elsif($node_name eq "MSG_TEXT")
        {
           $text=$sub_node->getData;
           $rA->[1]=$sub_node->getData;
            print $text;
           $node_name = "";
        }
    }    
}




###################################
=pod
obsolete version, for compatibility only


=cut
###################################
sub Connect2Shaul_old($$$){ #$xml_in,$xml_out
use strict;
use FileHandle;
use XML::DOM;
my ($MSG_OWNER, $MSG_MESSAGE,$file_out)=@_;
my $retcode = 0;


######################################
# in temporary way


#my $file = './msg_output.xml';
my $file = $$file_out;


my $parser = XML::DOM::Parser->new();
my $doc = $parser->parsefile ($file); 
#if($main::DEBUG)
{print $doc->toString  }


foreach my $node ($doc->getElementsByTagName ('MSG_TEXT')){ #get all tags in file, returned list of Elements
    #print $node -> getTagName;
        #print $node -> getNodeType;
    print $node -> getNodeName;
    my $subnode=$node -> getFirstChild;
    
    #my$attr = $node->getAttribute;
    #print $attr ->getValue;
    print my $node_value= $subnode -> getNodeValue;
    $subnode -> setNodeValue("$node_value MSG_OWNER =$MSG_OWNER, MSG_MESSAGE= $MSG_MESSAGE $free_text ") ;


    
    #$node -> setNodeValue("Mabat error:MSG_OWNER=$MSG_OWNER, MSG_MESSAGE=$MSG_MESSAGE ");
    
}
 
# Print doc file
$file="file_out.xml";
$doc->printToFile ($file);
$$file_out=$file;
#if($main::DEBUG)
{print $doc->toString  }


 # Avoid memory leaks - cleanup circular references for garbage collection
$doc->dispose;
#############################################################


return $retcode;
}
=======================================================
Tk example




    #use strict;
    use Tk;
sub GetServerProperties();


$MAX_LOG_STRING_LENGHT=80;
$GeneralIni = "\\\\ntticpt0\\ot_sr\\sys\\v1.0\\utl\\ManagementAndMonitoring_SERVER.INI";
$LogDir="\\\\ntticpt0\\ot_sr\\sys\\sysl";
 #my $main = new MainWindow;
 $main=MainWindow->new(-title => 'ManagementAndMonitoring_SERVER Properties View');
 $main->bind('' => sub {
$xe = $main->XEvent;
$main->maxsize($xe->w, $xe->h);
$main->minsize($xe->w, $xe->h);
});
     my $label = $main->Label(-text => 'Monitored Servers')->pack;
    $listbox=$main->Listbox("-width"=>25,"-height"=>15)->pack(-side => 'left');
#get servers list from INI
    $i=1;
    while(($ServName = `getinienvindex $GeneralIni SERVERS SERVER $i`))
    {
        push(@Servers,$ServName);
        $i++;
    }
    
    
# $listbox->insert('end',"NTTICPT0","B2CInt","WWWSRV1","TEST") ;
 $listbox->insert('end',@Servers) ;
 
 $listbox->bind('<Double-1>', \&getServerName);
 
$text1= $main->Text("-width"=>50,"-height"=>10)->pack(-fill => "both", -expand => 1);
$main->Button(-text => 'Quit',
                    -command => [$main => 'destroy']
                   )->pack;
    MainLoop;




sub getServerName{
    $ServerName=$listbox->get('active');


  
    $text1->delete('1.0','end');
    #$text1->insert('end',$ServerName);
    GetServerProperties();
    $ToDisplay="ID=$ID\nDescription=$Description\nRemoteLogDir=$RemoteLogDir  $monitored_resources_string";
 $monitored_resources_string="";
    
    $text1->insert('end',$ToDisplay);


#dialogbox with List of resources
    $dialog = $main->DialogBox( -title => $ServerName,
    -buttons => [ "Ok", "Cancel" ], );     
    $dialog->add("Label", -text => "Monitored Resources")->pack();


  #  $label1=$dialog->Label("-width"=>25,-text=>"Unknown")->pack(-fill => "both", -expand => 1);
   # $label1->configure(-relief => 'raised');
    
    $Sentry = $dialog->Listbox("-width"=>25,"-height"=>15)->pack(-side => 'left', -expand => 1);;
    $Sentry->insert('end',@Monitored_Resources);
#$entry1=$dialog->Entry("-width"=>50,-state=>'readonly')->pack(-fill => "both", -expand => 1);
  #  $entry1=$dialog->Entry("-width"=>50,-state=>'readonly')->pack();
$Sentry->bind('<Double-1>', \&getResourceStatus);


    $button = $dialog->Show();
 #   if($button eq "Ok") {
     if($button){
         @Monitored_Resources=(); #destroy 
        
    }


    
}


sub GetServerProperties(){
    #foreach $Server (@Servers) {
    $ID=`getinienv $GeneralIni $ServerName ID`;
    $Description=`getinienv $GeneralIni $ServerName DESCRIPTION`;
    $RemoteLogDir=`getinienv $GeneralIni $ServerName REMOTE_LOG_DIR`;


    my $i=1;
    while (($monitored_resource = `getinienvindex $GeneralIni $ServerName monitored_resources $i`) ne ""){
        push @Monitored_Resources,$monitored_resource;
        $monitored_resources_string=$monitored_resources_string."\nmonitored_resource= ".$monitored_resource;
        $i++;        
    }


sub getResourceStatus(){
$ResourceName=$Sentry->get('active');
#$entry1->delete("1.0",'end');


#$label->configure(-relief => 'raised');
$local_log_file="$LogDir\\$ServerName\\$ResourceName";
my $local_log_string;my$strToDisplay;
if($label) {$label->destroy();}
unless (open(LOG,$local_log_file)  ){$strToDisplay="Cann't open $local_log_file "; }
else{
    
seek(LOG,-($MAX_LOG_STRING_LENGHT+2),2); #goto end of file
        read LOG,$local_log_string,$MAX_LOG_STRING_LENGHT; #read last string
     
#$entry1=$dialog->Entry("-width"=>50,-state=>'readonly')->pack(-fill => "both", -expand => 1);
my($MonitoredResource, $Name,$Status,$LastTime)=split(" $local_log_string");
$lastKnownStatus=($Status==0)?"Ok":"Failed";
 $strToDisplay = " Last known status is $lastKnownStatus \n $local_log_string";
close LOG;
}
#$strToDisplay="MonitoredResource: $MonitoredResource\nName: $Name\n
$label=$dialog->Label(-text=>$strToDisplay)->pack();;




}    
   
 #}   
   


}    
#$topwindow=MainWindow(new);
=commented
$main = MainWindow -> new;
$butn = $main->Button(-text => 'bell');
     $butn->configure(-command => sub{ $butn->bell; });
     $butn->pack();
     MainLoop;


$main = MainWindow -> new;
     $but = $main->Button(-text => 'bell', 
                          -command => sub{ringit($main)})->pack;
     MainLoop;


     sub ringit { 
         my $m = shift; 
         $m->bell; 
     }


    use strict;
    use Tk;
     my $main = new MainWindow;
     my $label = $main->Label(-text => 'Hello World!');
     my $button = $main->Button(-text => 'Quit',
                                -command => sub{exit});
     $label->pack;  #no "my" necessary here
     $button->pack; #or here
     MainLoop;
=cut         


================================
XML example;


use XML::LibXML;


use strict;
use warnings;


my $parser = XML::LibXML->new;
my $doc = $parser->parse_file("books.xml");
my $XPATH_EXPRESSION=shift;
my @nodes = $doc->findnodes($XPATH_EXPRESSION);
# Вывести текст элементов title
foreach my $node (@nodes) {
print $node->firstChild->data, "\n";
}

