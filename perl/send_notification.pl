#!/usr/bin/perl
#This module send mail with html content  to number of recipience 
#and change specific pattern in predefined html template (optinally)
#Arguments : $pattern_to_change - pattern_to_change for example temporary rev label name .
#$mail_format - template file ,$SubjectFileName - subject file name ,
#needed to put email subject in Hebrew - The subject must be written to file .
#$address_to_send - the list of addresses in the following format :
#henrik.koren1@orange.co.il,stella.sokolovsky@orange.co.il

#changed by Bronfman 


sub send_mail  {

$FUNCNAME=(caller(0))[3];
#arguments:
my ( $mail_format, $SubjectFileName, $address_to_send,@mail_body )=@_;

print "Inside of send_notification\n";
print "$FUNCNAME $mail_body \n";
print $mail_format "\n";
print $SubjectFileName "\n";
print $address_to_send "\n";

#use strict;
use Data::Dumper;
use lib "perl/lib";
use Mail::Mailer;


open(HEB_DATA,"<$SubjectFileName") || die " Error: fail to open file $SubjectFileName for read";
my @HEB_DATA = <HEB_DATA>;
foreach $elem (@HEB_DATA)
{
 $my_subject = $elem;
#    	chomp($elem);
}

close(HEB_DATA);

my $mail = Mail::Mailer -> new('sendmail'); #send by system sendmail utility
open (MAIL,"$mail_format") || die "couldnt open mail format: $!";
#my comment  open (LIST,"<$LIST") || die "couldnt open mail format: $!";

 
$mail-> open (   {
                        To => "$address_to_send",
                        #Cc => "amonasti, istrahov, irokhk1x",
			                  'Content-type' => "text/html",
                        Subject => "$my_subject",
                        }
                    );

#print $mail "$text\<br\>";
while (<MAIL>){
#foreach $str (@mail_body){
    print $mail $_;
  #print $mail $str," \<br\>";
}


#	print $mail "\<\/span\>";

#}		 
		 
		 
close(MAIL);
	
$mail->close() || die "Can't send mail : $!\n";

}




