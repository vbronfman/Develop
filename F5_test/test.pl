#test.pl
#Receive at inout txt file, process it to output
print "Started", "\n";

#die 1 unless (-e $ARGV[1]);

$i=0;

while (<>){
    chomp;
    print ${i}++." ", join ' checked ', split, "\n";
}

print "Finished", "\n";
