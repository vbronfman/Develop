#!perl

use strict;
use warnings;
use Test::More tests => 20;

use No::Worries::Date qw(*);

our($string, $time, $tmp);

$string = date_string();
is(length($string), 20, "date_string() length");

$string = date_stamp();
is(length($string), 19, "date_stamp() length");

$time = time();
$string = date_string($time);
ok($string =~ /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ$/, "date_string() match [integer]");
$tmp = date_parse($string);
is($time, $tmp, "time -> date_string() -> time [integer]");

$time = time();
$string = date_stamp($time);
ok($string =~ /^\d\d\d\d\/\d\d\/\d\d-\d\d:\d\d:\d\d$/, "date_stamp() match [integer]");
$tmp = date_parse($string);
is($time, $tmp, "time -> date_stamp() -> time [integer]");

$time = time() . ".123";
$string = date_string($time);
ok($string =~ /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\.\d+Z$/, "date_string() match [fractional]");
$tmp = date_parse($string);
is($time, $tmp, "time -> date_string() -> time [fractional]");

$time = time() . ".123";
$string = date_stamp($time);
ok($string =~ /^\d\d\d\d\/\d\d\/\d\d-\d\d:\d\d:\d\d\.\d+$/, "date_stamp() match [fractional]");
$tmp = date_parse($string);
is($time, $tmp, "time -> date_stamp() -> time [fractional]");

foreach $string (
    "Wed, 09 Feb 1994 22:23:32 GMT", # HTTP format
    "Thu Feb  3 17:03:55 GMT 1994",  # ctime(3) format
    "Thu Feb  3 00:00:00 1994",,     # ANSI C asctime() format
    "03/Feb/1994:17:03:55 -0700",    # common logfile format
    "09 Feb 1994 22:23:32 GMT",      # HTTP format (no weekday)
    "08-Feb-94 14:15:29 GMT",        # rfc850 format (no weekday)
    "1994-02-03 14:15:29 -0100",     # ISO 8601 format
    "1994-02-03 14:15:29",           # zone is optional
    "19940203T141529Z",              # ISO 8601 compact format
    ) {
    $time = date_parse($string);
    ok($time =~ /^\d+$/, "parse $string");
}

eval { $time = date_parse("Not a date!") };
ok($@, "invalid date");
