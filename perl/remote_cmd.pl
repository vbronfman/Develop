
use lib "./Net-SSH-Perl-1.34/lib";
use lib 'C:\Documents and Settings\vbronfman\My Documents\Downloads\PERL\Net-OpenSSH-0.52\lib';

use Net::SSH::Perl; #doesn't work - some modules are absent
use Net::OpenSSH; #doesn't work under Windows


sub remote_cmd{
 
my($user,$pass,$host,$cmd)=@_;


print "\nCONNECT= $user $host $cmd    ";

my $ssh = Net::SSH::Perl->new($host);
    $ssh->login($user, $pass);
    my($stdout, $stderr, $exit) = $ssh->cmd($cmd);
    
    


if($?) {
    print "     error $?\n";
    return $?
}
@resp=split(/ /,@responce[@responce-1]);
return $?;
}

#############################################
#   MAIN
#############################################

    

while(<DATA>){
    chomp;
    @connection_str=(split/ /,$_);
print ("Connecting to @connection_str");

if (remote_cmd(@connection_str,"uptime")){
    print "Error\n";
    
}
##print "responce $resp[3]";
#if ($resp[3] > 180 ){
#    print "$host is outdated: $resp[3] days up!!! \n"
#    
#}
#print "responce @resp";

}

__DATA__
oracle oracle it1tst1
oracle oracle it2tst1
oracle oracle it3tst1
oracle oracle it4tst1
oracle oracle it5tst1
oracle oracle vmbilinftst1
oracle oracle zvantst1
oracle oracle @erpdbtst2
tibco55@kermit
bscstst1@znbillapptst1
oracle@znbilldbtst1
oracle@znIFtst1
oracle@itlabdb3
oracle@mindy
oracle@ifbltest1
oracle@ifbltest2