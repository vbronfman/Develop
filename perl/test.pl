 $pwd = (getpwuid($<))[1];

 system "stty -echo";
 print "Password: ";
 chomp($word = <STDIN>);
 print "\n";
 system "stty echo";

 if (crypt($word, $pwd) ne $pwd) {
     die "Sorry...\n";
 } else {
     print "ok\n";
 }