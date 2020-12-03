# you can write to stdout for debugging purposes, e.g.
# print "this is a debug message\n";

sub solution {
    my (@A)=@_;
    # write your code in Perl 5.18
    #find max
    my @a=sort { $a <=> $b } @A;
    return 1 if ($a[-1] < 0 );
    @b;
    for (my $i;$i<=@a; $i++){
        next if ($a[i]<0);
        next if ($a[$i+1] == $a[i]+1);
        if ($a[$i+1] != $a[i]+1 ) {
            push @b,$a[$i]+1;
        }
           
    
    }
    print @b;
        return $b[0]; #min
}

my @arr= [1, 3, 6, 4, 1, 2];
solution(@arr);
