#/usr/bin/perl
#this programm propose - to send email notification to developers before build version 
#it create temp revision label and send it's name to developers ,
# the developers will attach this label to relevant files 
#All variables definitions I'll place to Global_conf.pl file 
#If the label already exist - the program will send email with existing label -
# don't warry if you have message : Error occurred:
#The label was not updated. A revision label with that name is already defined for this view.

######## MAIN ########

do ("/home/test_user/orange_dev/Global_Conf.pl");
do ("$Program_Home\/parse_inifiles.pl");
do ("$Program_Home\/send_notification.pl");
$template_file = "$Program_Home\/templates/new2.html";
$subject_file = "$Program_Home\/templates/subject";

#Below is a format - you can enter many addresses - you can add them to Project_view.ini
# $user_name = "stella.sokolovsky\@orange.co.il";
# $user_name1 = "susha210280\@hotmail.com";
# $addresses = $user_name .",". $user_name1;
($Project_conf_obj, @stam) = parse_ini_files ( $Projects_view );

 foreach $sec ($Project_conf_obj->Sections)
 {
   $Label_name = $sec;
   $ST_Project =$Project_conf_obj->val( $sec, 'view_name');
   #$Label_name = $Project_conf_obj->val( $sec, 'tmp_label_name');
   $mail_address = $Project_conf_obj->val( $sec, 'mail_addresses');
   
   $mail_address =~ s/\"//g;
   #$COM = "stcmd label -x -r -nl $Label_name -p $ST_user:$ST_passwd\@$ST_server_port\/$ST_Project";
   $COM = "stcmd label -p \"$ST_user:$ST_passwd\@$ST_server_port\/$ST_Project\" -x -nl $Label_name -vl master_view_label";
   $status = system ($COM);
   # $COM = "stcmd label -x -nl $Label_name -p $ST_user:$ST_passwd\@$ST_server_port\/$ST_Project";
   # $status = system ($COM);
   #$user = $ST_user;

   &send_mail($Label_name , $template_file, $subject_file ,$mail_address);	
 }
 exit;
