#!perl

use strict;
use warnings;
use Test::More tests => 14;
use File::Temp qw(tempdir);

use No::Worries::File qw(*);

our($dir, $path, $str, $len, $tmp);

$dir = tempdir(CLEANUP => 1);
$path = "$dir/tst";

# empty

$str = "";
$len = length($str);

file_write($path, data => $str);
is(-s $path, $len, "write empty");
$tmp = file_read($path);
is($tmp, $str, "read empty");

# non-empty

$str = "Test with '\x{c3}\x{a9}' char"; # Latin small letter e with acute, UTF-8 encoded
$len = length($str);

file_write($path, data => $str);
is(-s $path, $len, "write plain");
file_write($path, data => $str, binmode => "binary");
is(-s $path, $len, "write binary");

$tmp = file_read($path, binmode => "binary");
is($tmp, $str, "read binary");
$tmp = file_read($path);
is($tmp, $str, "read plain");
$tmp = file_read($path, binmode => "utf8");
is(length($tmp), $len-1, "read utf8");
file_write($path, data => $tmp, binmode => "utf8");
is(-s $path, $len, "write utf8");

# error

unlink($path) or die;
eval { file_read($path) };
ok($@ =~ /cannot open/, "no such file");

# by ref

$str = "abc=def\n";
$len = length($str);

file_write($path, data => \$str);
$tmp = file_read($path);
is($tmp, $str, "write by ref + read");
$tmp = "";
file_read($path, data => \$tmp);
is($tmp, $str, "write by ref + read by ref");

file_write($path, data => \"with constant too!");
is(-s $path, 18, "write by const ref");

# by sub

$str = "abc=def\n";
$len = length($str);
$tmp = $str;

file_write($path, data => sub {
    my $chunk = substr($tmp, 0, 3);
    substr($tmp, 0, 3) = "";
    return($chunk);
});
$tmp = file_read($path);
is($tmp, $str, "write by sub + read");
$tmp = "";
file_read($path, data => sub {
    $tmp .= $_[0];
});
is($tmp, $str, "write by sub + read by sub");
