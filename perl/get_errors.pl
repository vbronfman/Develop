
$MASK_BEGIN="ERROR";
$MASK_END="END OF ERROR";

open(IN,'<',$ARGV[0]) or die "Can not open $ARGV[0]";

while(<IN>){

$OPEN_SECTION=1 if(/$MASK_BEGIN/);
 if((~!/END OF ERROR/) && ($OPEN_SECTION==1)){
    push @message,$_; #add every string into array
 }
 
 $OPEN_SECTION=0 if(/$MASK_END/) ;
}

print @message;
close IN;