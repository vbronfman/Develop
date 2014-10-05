#package HTML_Engine;
#!/usr/bin/perl

#############################################
# <monitor_html.pl> - prepare and send notification
#
# Developed by V.Bronfman
# Comments:
# Dependencies:
#
#############################################

use Partner::Init;
use File::Basename;
use File::Copy;
use Data::Dumper;

use sigtrap 'handler', \&sig_handler, 'normal-signals';

#######################################
# Global variables
#######################################
$LOG="${0}_$$.log";
$DEBUG=0;
#######################################
# functions
#######################################

#######################################
# sig_handler() - catch INT signal
#  
#sigtrap - Perl pragma to enable simple signal handling
#use sigtrap 'handler' => \&my_handler, 'normal-signals';
#######################################
sub sig_handler
{
    print STDERR "INT signal received!!!\n";
    die "\n caught $SIG{INT}",@_,"\n";
    #exit; 
}


sub AUTOLOAD {
use Carp;
croak "Function $AUTOLOAD not defined!";
#confess;
#warn "Function $AUTOLOAD not defined!";
}

#######################################
# main
#######################################
$RET=0;
sub create_html {
    
    my($account, $cmd, $timeout)=@_;
    $FUNCNAME=(caller(0))[3];
    
use Template;

#$Template::Stash::PRIVATE = undef;
# some useful options (see below for full list)
my $config = {
#    INCLUDE_PATH => './templates',  # or list ref
    INCLUDE_PATH => $template_dir,  # or list ref
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 1,               # cleanup whitespace
    #PRE_PROCESS  => 'header',        # prefix each template
    EVAL_PERL    => 1,               # evaluate Perl code blocks
};
 
# create Template object
my $template = Template->new($config);
 
print "$FUNCNAME \n";
print Dumper (@TO_RUN);
# define template variables for replacement
my $vars = {
    var1  => $account, #not in use
    #var2  => \%hash,
    var3  => \@{TO_RUN},
    #var4  => \&code,
    #var5  => \$object,
};
 
# specify input filename, or file handle, text reference, etc.
#my $input = 'mail_template.tt';
#$out_html="monitor_mail.html";
 
# process input template, substituting variables
writelog "\n\n \$out_html = $out_html \n\n";
$template->process($input_template, $vars, $out_html)
    || die $template->error();
#my()=@ARGV;

writelog ("Finished");

return $RET;
}

1;