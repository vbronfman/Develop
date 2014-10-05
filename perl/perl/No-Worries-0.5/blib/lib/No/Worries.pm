#+##############################################################################
#                                                                              #
# File: No/Worries.pm                                                          #
#                                                                              #
# Description: coding without worries                                          #
#                                                                              #
#-##############################################################################

#
# module definition
#

package No::Worries;
use strict;
use warnings;
our $VERSION  = "0.5";
our $REVISION = sprintf("%d.%02d", q$Revision: 1.18 $ =~ /(\d+)\.(\d+)/);

#
# global variables
#

our($ProgramName);

#
# trim leading and trailing spaces (private)
#

sub _sptrim ($) {
    my($string) = @_;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return($string);
}

#
# export control helper (private)
#

sub _import ($$$@) {
    my($callpkg, $pkg, $exported, @names) = @_;
    my($name);

    while (@names) {
	$name = shift(@names);
	die("\"$name\" is not exported by the $pkg module\n")
	    unless $name eq "*" or $exported->{$name};
	if ($name eq "*") {
	    # all normal symbols
	    unshift(@names, grep(!ref($exported->{$_}), keys(%$exported)));
	} elsif (ref($exported->{$name}) eq "CODE") {
	    # special
	    $exported->{$name}->($name);
	} elsif ($name =~ /^(\w+)$/) {
	    # function
	    no strict qw(refs);
	    *{"${callpkg}::${1}"} = \&{"${pkg}::${1}"};
	} elsif ($name =~ /^\$(\w+)$/) {
	    # scalar
	    no strict qw(refs);
	    *{"${callpkg}::${1}"} = \${"${pkg}::${1}"};
	} else {
	    die("unsupported export by the $pkg module: $name\n");
	}
    }
}

#
# module initialization
#

$ProgramName = $0;
$ProgramName =~ s/^.*\///;
$ProgramName = _sptrim($ProgramName);

#
# export control
#

sub import : method {
    my($pkg, %exported);

    $pkg = shift(@_);
    grep($exported{$_}++, qw($ProgramName));
    _import(scalar(caller()), $pkg, \%exported, @_);
}

1;

__DATA__ 

=head1 NAME

No::Worries - coding without worries

=head1 SYNOPSIS

  use No::Worries qw($ProgramName);

  printf("program is %s\n", $ProgramName);

=head1 DESCRIPTION

This module and its sub-modules ease coding by providing consistent
convenient functions to perform frequently used programming tasks.

This module also exposes the $ProgramName variable that represents
what the modules think the program name is. This variable can be
changed if needed.

=head1 PROGRAMMING STYLE

=head2 ERROR HANDLING

All the functions die() on error so one does not have to worry about
error checking: by default, any error will stop the code execution.
The recommended way to catch errors is to use eval().

For consistency, all the sub-modules use No::Worries::Die's dief() to
report errors and No::Worries::Warn's warnf() to report warnings. The
NO_WORRIES environment variable can be used to control how errors and
warnings are reported (see L<No::Worries::Die> and L<No::Worries::Warn>).

=head2 OPTION PASSING

All the functions use the same consistent API with hashes to pass
options like in:

  dir_make("/tmp/some/path", mode => 0770);

This is a bit overkill when only one option is supported but it allows
adding options later without breaking old code.

The options can also be passed via a hash reference (this can be
useful to avoid data copying):

  dir_make("/tmp/some/path", { mode => 0770 });

All the options are checked using L<Params::Validate>.

=head2 SYMBOL IMPORTING

All the modules are "clean" in the sense that they do not import any
symbol into the caller's namespace. All the needed symbols (usually
functions) have to be explicitly imported like in:

  use No::Worries::Die qw(dief);

In addition, all "normal" symbols can be imported at once using the
asterisk character:

  use No::Worries::Log qw(*);

=head1 MODULES

Here are the relevant sub-modules and what they provide:

=over

=item L<No::Worries::Date> - date handling:

=over

=item * date_parse(STRING)

=item * date_stamp([TIME])

=item * date_string([TIME])

=back

=item L<No::Worries::Die> - error handling:

=over

=item * dief(FORMAT, ARGUMENTS...)

=back

=item L<No::Worries::Dir> - directory handling:

=over

=item * dir_change(PATH)

=item * dir_ensure(PATH[, OPTIONS])

=item * dir_make(PATH[, OPTIONS])

=item * dir_parent(PATH)

=item * dir_read(PATH)

=item * dir_remove(PATH)

=back

=item L<No::Worries::DN> - Distinguished Names handling:

=over

=item * dn_parse(STRING)

=item * dn_string(DN, FORMAT)

=back

=item L<No::Worries::File> - file handling:

=over

=item * file_read(PATH[, OPTIONS])

=item * file_write(PATH[, OPTIONS])

=back

=item L<No::Worries::Log> - logging (log and filter information):

=over

=item * log_trace()

=item * log_debug(ARGUMENTS)

=item * log_info(ARGUMENTS)

=item * log_warning(ARGUMENTS)

=item * log_error(ARGUMENTS)

=item * log_wants_trace()

=item * log_wants_debug()

=item * log_wants_info()

=item * log_wants_warning()

=item * log_wants_error()

=item * log_filter(FILTER)

=item * log_configure(PATH)

=item * log2std(INFO)

=item * log2dump(INFO)

=back

=item L<No::Worries::PidFile> - pid file handling:

=over

=item * pf_set(PATH[, OPTIONS])

=item * pf_check(PATH[, OPTIONS])

=item * pf_touch(PATH)

=item * pf_unset(PATH)

=item * pf_status(PATH[, OPTIONS])

=item * pf_quit(PATH[, OPTIONS])

=back

=item L<No::Worries::Proc> - process handling:

=over

=item * proc_output(COMMAND...)

=item * proc_create(OPTIONS)

=item * proc_terminate(PROC[, OPTIONS])

=item * proc_monitor(PROCS[, OPTIONS])

=item * proc_run(OPTIONS)

=item * proc_detach([OPTIONS])

=back

=item L<No::Worries::Syslog> - syslog handling:

=over

=item * syslog_open([OPTIONS])

=item * syslog_close()

=item * syslog_sanitize(STRING)

=item * syslog_debug(FORMAT, ARGUMENTS...)

=item * syslog_info(FORMAT, ARGUMENTS...)

=item * syslog_warning(FORMAT, ARGUMENTS...)

=item * syslog_error(FORMAT, ARGUMENTS...)

=item * log2syslog(INFO)

=back

=item L<No::Worries::Warn> - warning handling:

=over

=item * warnf(FORMAT, ARGUMENTS...)

=back

=back

=head1 GLOBAL VARIABLES

This module uses the following global variables (that can all be imported):

=over

=item $ProgramName

the name of the currently running program (default: derived from $0)

=back

=head1 SEE ALSO

L<No::Worries::Date>,
L<No::Worries::Die>,
L<No::Worries::Dir>,
L<No::Worries::DN>,
L<No::Worries::File>,
L<No::Worries::Log>,
L<No::Worries::PidFile>,
L<No::Worries::Proc>,
L<No::Worries::Syslog>,
L<No::Worries::Warn>,
L<Params::Validate>.

=head1 AUTHOR

Lionel Cons L<http://cern.ch/lionel.cons>

Copyright CERN 2012
