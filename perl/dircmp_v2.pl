#!/usr/bin/perl
#
use Carp;  
use warnings;
use File::Basename;


#carp "This is a warning!";  
#croak "This is an error!";  #like die: print and exit
#confess "So long!";  #print message, stack and exit 

$DEBUG=0;
sub writelog (@){

    if(defined $log){
        print $log @_, "\n";
    }
    else {
        print @_, "\n";
    }
}

sub init(){

    usage() unless @ARGV;
    if($ARGV[0] ne 'debug'){
        open($log,'>>',"$0.log") or warn "cann't create $0.log";
    }
    else 
    {
        shift @ARGV; #remove "debug"
        $DEBUG=1;
    }
    
    if($ARGV[0] eq "remove"){
        shift @ARGV;
        $REMOVE=1;
    }
     
    writelog localtime()." $0 started ";
    
}

sub usage (){

$msg=<<MSG;
$0 - search for differences between directories. Run 'dircmp' at a background

Usage:
$0 <searchin> <filter> <output_file>
\tsearchin - root directory to search in
\tfilter -  mask of directories names
\toutput_file - file of versions
Example:
/users/b50krnd/product/bscs700/addon/src/.backup_RPE/dircmp.pl  /users/b50krnd/product/bscs700/addon/src/.backup_RPE 2011 /tmp/versions



MSG

print $msg;

exit 0;
}

sub remove_dirs(){
    
    use Tie::File;
    use File::Path;
    
    my @vers;
    tie @vers, 'Tie::File', $out or die "Cann't tie $out";
    die " vers array is empty  " unless(@vers)    ;
    
#    foreach $dir(@vers){
#    print $dir,"\n";
#}
    
    foreach $dir (@dirs){
        print ("dirname = $dir\n");
        if ((-d $dir) && !(grep (/$dir/,@vers))){
           
           writelog ("remove $dir");
           # rmtree ($dir , {error => \my $err} );
        #   if (@$err) {
        #        for my $diag (@$err) {
        #            my ($file, $message) = %$diag;
        #            if ($file eq '') {
        #                print "general error: $message\n";
        #            }
        #            else {
        #                print "problem unlinking $file: $message\n";
        #            }
        #        }
        #    }
        #    else {
        #        print "No error encountered\n";
        #    }
        }
        
    }
    untie @vers;            # all finished
}


#####################################################################
# MAIN
#####################################################################

$|=1;

$REMOVE=0;
$DEBUG=0;

init();
($root,$mask,$out)=@ARGV;
#foreach (`ls -tr $ARGV[0]`){
#chomp;
#push @dirs,$_;
#}
print "root=$root, mask=$mask,out=$out";
#opendir(DIR, $ARGV[0]) or die "Can not open input directory $ARGV[0] : $!";

#$dirname  = dirname($ARGV[0])."/";
$dirname  = $root."/";
#@dirs=map{chomp;$dirname.$_} `ls -trd $root/*$mask*`;
@dirs=map{chomp;$_} `ls -trd $root/*$mask*`;
#@dirs=map{$dirname.$_} ( grep {!/^\.{1,2}/} readdir (DIR));
die "empty dirs" if (@dirs<0);
#foreach $dir(@dirs){
#    print $dir,"\n";
#}

unless($REMOVE){

@vers=($dirs[0]); #direcories contain changes

for($i=1; $i<@dirs;$i++){
    next unless ($dirs[$i]=~/.*$mask.*/);
    print "compare $dirs[$i] to $dirs[$i-1] \n";

    if(`dircmp -s $dirs[$i] $dirs[$i-1] `){
        print "$dirs[$i] is different from $dirs[$i-1] \n";
        push @vers,"$dirs[$i]";
    }
    
}

open LOG,'>',$out or warn "Can not open $out:$!";
foreach $dir(@vers){
    print LOG $dir,"\n";
}
}
else { remove_dirs }
    
__END__
