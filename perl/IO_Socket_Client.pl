#!/usr/bin/perl -w
    use IO::Socket;
    unless (@ARGV > 1) { die "usage: $0 host url ..." }
    $host = shift(@ARGV);
    $EOL = "\015\012";
    $BLANK = $EOL x 2;
    for my $document (@ARGV) {
    $remote = IO::Socket::INET->new( Proto => "tcp",
    PeerAddr => $host,
   #  PeerPort => "http(80)",
    PeerPort => "$ARGV[1]",
    ) || die "cannot connect to httpd on $host";
    $remote->autoflush(1);
    print $remote "GET $document HTTP/1.0" . $BLANK;
    while ( <$remote> ) { print }
    close $remote;
    }
    
    use Config;