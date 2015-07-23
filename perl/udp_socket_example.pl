#!/usr/bin/perl -w
# udpqotd - UDP message server
#grabbed from Perl CoockBook http://docstore.mik.ua/orelly/perl/cookbook/ch17_06.htm
# Modified by Bronfman on 2015/07/22

use strict;
use IO::Socket;
use Data::Dumper;


my($sock, $oldmsg, $newmsg, $hisaddr, $hishost, $MAXLEN);
my ($PORTNO, $myINADDR_BROADCAST, )=@ARGV;

$MAXLEN = 1024;
$PORTNO ||= 5151;
$myINADDR_BROADCAST ||='194.29.37.255';

sub send_broad_msg {
    my $sock = IO::Socket::INET->new(
        LocalPort => $PORTNO,    
        Proto    => 'udp',
        PeerPort => $PORTNO,
        PeerAddr => $myINADDR_BROADCAST,
        Broadcast    =>1,
    ) or die "Could not create socket: $!\n";

$sock->send('New dispatcher is starting') or die "Send error: $!\n";
$sock->close;
    
}


print "Send broadcast\n", send_broad_msg;
$sock = IO::Socket::INET->new(LocalPort => $PORTNO,   Proto => 'udp',
                              )
    or die "socket: $@";

print "Awaiting UDP messages on port $PORTNO\n";
$oldmsg = "This is the starting message.";

#$sock->setsockopt()

while ($sock->recv($newmsg, $MAXLEN)) {
    my($port, $ipaddr) = sockaddr_in($sock->peername);
    $hishost = gethostbyaddr($ipaddr, AF_INET);
    die "THere is instance of dispatcher on air\n" if ($newmsg eq "exists");
    print "Client $hishost  from $port said:  $newmsg\n";

    $sock->send("exists"); # send msg in responce to new process starting.
    
}

die "recv: $!";
