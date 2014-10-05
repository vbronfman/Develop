#+##############################################################################
#                                                                              #
# File: No/Worries/File.pm                                                     #
#                                                                              #
# Description: file handling without worries                                   #
#                                                                              #
#-##############################################################################

#
# module definition
#

package No::Worries::File;
use strict;
use warnings;
our $VERSION  = "0.5";
our $REVISION = sprintf("%d.%02d", q$Revision: 1.10 $ =~ /(\d+)\.(\d+)/);

#
# used modules
#

use No::Worries qw();
use No::Worries::Die qw(dief);
use Params::Validate qw(validate :types);

#
# global variables
#

our($DefaultBufSize);

#
# binmode() helper
#

sub _binmode ($$$) {
    my($path, $fh, $mode) = @_;

    if ($mode eq "utf8") {
	binmode($fh, ":encoding(utf8)")
	    or dief("cannot binmode(%s, :encoding(utf8)): %s", $path, $!);
    } else {
	binmode($fh)
	    or dief("cannot binmode(%s): %s", $path, $!);
    }
}

#
# read from a file
#

my %file_read_options = (
    binmode => { optional => 1, type => SCALAR, regex => qr/^(binary|utf8)$/ },
    bufsize => { optional => 1, type => SCALAR, regex => qr/^\d+$/ },
    data    => { optional => 1, type => SCALARREF | CODEREF },
);

sub file_read ($@) {
    my($path, %option, $fh, $ref, $contents, $done);

    $path = shift(@_);
    %option = validate(@_, \%file_read_options) if @_;
    $option{bufsize} ||= $DefaultBufSize;
    open($fh, "<", $path) or dief("cannot open(%s): %s", $path, $!);
    _binmode($path, $fh, $option{binmode}) if $option{binmode};
    $done = -1;
    $ref = $option{data} ? ref($option{data}) : "";
    if ($ref eq "SCALAR") {
	${$option{data}} = "";
	while ($done) {
	    $done = sysread($fh, ${$option{data}}, $option{bufsize},
			    length(${$option{data}}));
	    dief("cannot sysread(%s): %s", $path, $!) unless defined($done);
	}
	$contents = $option{data};
    } elsif ($ref eq "CODE") {
	while ($done) {
	    $done = sysread($fh, $contents, $option{bufsize});
	    dief("cannot sysread(%s): %s", $path, $!) unless defined($done);
	    $option{data}->($contents) if $done;
	}
	$contents = $option{data}->("");
    } else {
	$contents = "";
	while ($done) {
	    $done = sysread($fh, $contents, $option{bufsize}, length($contents));
	    dief("cannot sysread(%s): %s", $path, $!) unless defined($done);
	}
    }
    close($fh) or dief("cannot close(%s): %s", $path, $!);
    return($contents);
}

#
# write to a file
#

my %file_write_options = (
    binmode => { optional => 1, type => SCALAR, regex => qr/^(binary|utf8)$/ },
    bufsize => { optional => 1, type => SCALAR, regex => qr/^\d+$/ },
    data    => { optional => 0, type => SCALAR | SCALARREF | CODEREF },
);

sub file_write ($@) {
    my($path, %option, $fh, $ref, $offset, $length, $done, $chunk);

    $path = shift(@_);
    %option = validate(@_, \%file_write_options);
    $option{bufsize} ||= $DefaultBufSize;
    open($fh, ">", $path) or dief("cannot open(%s): %s", $path, $!);
    _binmode($path, $fh, $option{binmode}) if $option{binmode};
    $offset = 0;
    $ref = ref($option{data});
    if ($ref eq "SCALAR") {
	$length = length(${$option{data}});
	while ($length) {
	    $done = syswrite($fh, ${$option{data}}, $option{bufsize}, $offset);
	    dief("cannot syswrite(%s): %s", $path, $!) unless defined($done);
	    $length -= $done;
	    $offset += $done;
	}
    } elsif ($ref eq "CODE") {
	while (1) {
	    $chunk = $option{data}->();
	    $length = length($chunk);
	    last unless $length;
	    $offset = 0;
	    while ($length) {
		$done = syswrite($fh, $chunk, $option{bufsize}, $offset);
		dief("cannot syswrite(%s): %s", $path, $!) unless defined($done);
		$length -= $done;
		$offset += $done;
	    }
	}
    } else {
	$length = length($option{data});
	while ($length) {
	    $done = syswrite($fh, $option{data}, $option{bufsize}, $offset);
	    dief("cannot syswrite(%s): %s", $path, $!) unless defined($done);
	    $length -= $done;
	    $offset += $done;
	}
    }
    close($fh) or dief("cannot close(%s): %s", $path, $!);
}

#
# module initialization
#

$DefaultBufSize = 1_048_576; # 1MB

#
# export control
#

sub import : method {
    my($pkg, %exported);

    $pkg = shift(@_);
    grep($exported{$_}++, map("file_$_", qw(read write)));
    No::Worries::_import(scalar(caller()), $pkg, \%exported, @_);
}

1;

__DATA__

=head1 NAME

No::Worries::File - file handling without worries

=head1 SYNOPSIS

  use No::Worries::File qw(file_read file_write);

  # read a file
  $data = file_read($path);

  # idem but with data returned by reference
  file_read($path, data => \$data);

  # write a file
  file_write($path, $data => "hello world");

  # idem but with data passed by reference
  file_write($path, $data => \"hello world");

=head1 DESCRIPTION

This module eases file handling by providing convenient wrappers
around standard file functions. All the functions die() on error.

=head1 FUNCTIONS

This module provides the following functions (none of them being
exported by default):

=over

=item file_read(PATH[, OPTIONS])

read the file at the given path and return its contents; supported
options:

=over

=item * C<binmode>: binary mode to use (see below)

=item * C<bufsize>: buffer size to use for I/O operations

=item * C<data>: return the file contents via this scalar reference or
code reference (see below)

=back

=item file_write(PATH[, OPTIONS])

write the given contents to the file at the given path; supported
options:

=over

=item * C<binmode>: binary mode to use (see below)

=item * C<bufsize>: buffer size to use for I/O operations

=item * C<data>: provide the file contents via this scalar, scalar
reference or code reference (see below)

=back

=back

=head1 OPTIONS

All the functions support a C<binmode> option specifying how the file
should be accessed:

=over

=item * C<binary>: binmode(FH) will be used to treat the file as binary

=item * C<utf8>: binmode(FH, ":encoding(utf8)") will be used to select
UTF-8 encoding

=item * otherwise: binmode() will not be used (this is the default)

=back

file_read() can be given a code reference via the C<data> option.
Each time data is read via sysread(), the subroutine will be called
with the read data. At the end of the file, the subroutine will be
called with an empty string.

file_write() can be given a code reference via the C<data> option. It
should return data in a way similar to sysread(), returning an empty
string to indicate the end of the data to write to the file.

=head1 GLOBAL VARIABLES

This module uses the following global variables (none of them being
exported):

=over

=item $DefaultBufSize

default buffer size to use for I/O operations if not specified via the
C<bufsize> option (default: 1MB)

=back

=head1 SEE ALSO

L<No::Worries>.

=head1 AUTHOR

Lionel Cons L<http://cern.ch/lionel.cons>

Copyright CERN 2012
