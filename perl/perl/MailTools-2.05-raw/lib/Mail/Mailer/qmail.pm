
use strict;

package Mail::Mailer::qmail;
use base 'Mail::Mailer::rfc822';

sub exec($$$$)
{   my($self, $exe, $args, $to, $sender) = @_;
    my $address = defined $sender && $sender =~ m/\<(.*?)\>/ ? $1 : $sender;

    exec($exe, (defined $address ? "-f$address" : ()));
    die "ERROR: cannot run $exe: $!";
}

1;
