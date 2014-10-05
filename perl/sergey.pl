#!perl
#use strict;
sub test() {

$i=100000;

 #print "i= $i";

                for $i (1,3,5,7) {

                                print " ******* $i \n";

                                last if ($i == 3);

                }

                print " ~~~~~~~ $i \n";

 

                for ($i=0; $i<4; ) {

                                print " ******* $i \n";

                                last if ($i == 2);$i++

                }

                print " ~~~~~~~ $i \n";

}


test

