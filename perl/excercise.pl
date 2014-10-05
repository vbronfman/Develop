
my ($file) = @ARGV;
open (IN,$file) or die "cann't open: $?";
$section =0;
my @log=();
my %FMB=();

while(<IN>){
    #chomp;

    if(~/compiling (.*\.fmb)/ || $section ) { #'Form not created'
        $fmb=$1;
#        print;
          push @log,$_;
        
        if(/Created form file /){
            $FMB{$fmb}=undef ;# success
            $section=0;
            @log=();
            next;
        }
        elsif (/Form not created/){
            @{$FMB{$fmb}}=@log;
            $section=0;
            @log=();
            next;
        }
    }
    
}

close IN;
 my $errors_num=0; 
while (($key, $value) = each %FMB) {
  
    if (defined $value){
        $errors_num++;
        print "$errors_num $key \n";
        #print @$value ;
        for(my $i=0; $i<@$value;$i++){
            next if ($value->[$i]=~/^$/ || $value->[$i+1]=~/^$/ || $value->[$i+1]=~/No compilation errors/); 
            print $value->[$i]."\n";
        }
        print "#"x20,"\n";
    }
}

print "END";


__END__

my $str = '112133';

$str =~ s/(.)\1/$1/g;
####################
my $var;

if (exists $var->{key1}->{key2}) {
    $var->{key1}->{key2} = 1;
}

my $keys = keys(%{$var});


$r = \ (1,2,3);

while(<DATA>){
($user,$pid,$cpu,$mem)=split;
$users{$user}[0]++;
#mem
$users{$user}[1]+$mem;
    
    
}



$rA=[ [2,4,5], [3,3,3], [4,4,4]];

print $$rA[0]->[2];

$rLists=[ (2,4,5), (3,3,3), (4,4,4)];

print $$r;

$refHash={a=>3,b=>2};
print keys %$refHash;

$rH = {a=>1, b=>2, c=>3};
ref $rH;
ref($rH);

__DATA__
root     28756 28683  0 Jan02 ?        00:00:00 /bin/sh - /usr/lib/vxvm/bin/vxcached root
oracle   29748     1  0 Jan02 ?        21:20:16 /app01/oracle/product/10.2.0.4/bin/tnslsnr LISTENER -inherit
root     30737     1  0 May05 ?        00:00:00 cupsd
root     31115     1  0 Jan02 ?        00:00:00 xinetd -stayalive -pidfile /var/run/xinetd.pid
ntp      31386     1  0 Jan02 ?        00:00:07 ntpd -u ntp:ntp -p /var/run/ntpd.pid -g
root     31722 28685  0 Jan02 ?        00:00:00 vxnotify
root     31723 28685  0 Jan02 ?        00:00:00 /bin/sh - /usr/lib/vxvm/bin/vxconfigbackupd
root     31839     1  0 Jan02 ?        00:06:51 /opt/VRTSob/bin/vxsvc -r /etc/vx/isis/Registry -e
root     31861     1  0 Jan02 ?        00:00:07 /usr/ecc/exec/mstragent
root     31878 31861  0 Jan02 ?        00:05:31 /usr/ecc/exec/mstragent -s
root     31879     1  0 Jan02 ?        00:00:00 /esm/bin/lnx-x86/esmd -fv
root     31925     1  0 Jan02 ?        00:00:00 /opt/VRTSobc/pal33/bin/vxpal -a gridnode -x
root     31978     1  0 Jan02 ?        00:11:52 /opt/VRTSobc/pal33/bin/vxpal -a StorageAgent -x
root     32029     1  0 Jan02 ?        00:23:40 /usr/ecc/exec/MLR610/mlragent
root     32065     1  0 Jan02 ?        00:37:58 /opt/VRTSsfmh/bin/xprtld -X 1 /etc/opt/VRTSsfmh/xprtld.conf