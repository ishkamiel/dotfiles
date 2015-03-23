package Printing;

use strict;
use warnings;
use Exporter;
use File::Find;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA     = qw(Exporter);
    our @EXPORT =
      qw(p_debug p_info p_warn p_error p_tell p_doing p_executing enableVerbose enableDebugOutput);
    our @EXPORT_OK = qw();
}

use Term::ANSIColor;

my $have_ansicolor = 1;

use constant {
    P_DEBUG => "[DD] ",
    P_INFO  => "[II] ",
    P_WARN  => "[WW] ",
    P_ERROR => "[EE] ",
    P_TELL  => "[  ] ",
    P_DO    => "[--] ",
    P_EXEC  => "[**] ",
    C_DEBUG => 'white',
    C_INFO  => 'white',
    C_WARN  => 'magenta',
    C_ERROR => 'red',
    C_TELL  => 'bright_cyan',
    C_DO    => 'bright_yellow',
    C_EXEC  => 'bright_green',
};

my $DEBUG   = '';
my $VERBOSE = '';

sub enableVerbose {
    $VERBOSE = 1;
}

sub enableDebugOutput {
    $VERBOSE = $DEBUG = 1;
}

sub printc {
    my $c = shift;

    if ($have_ansicolor) {
        my $str = join( '', @_ ); 
        $str =~ s/^\s+|\s+$//g;

        if ($str =~ m/^(.*)###(.*)###(.*)$/) {
            $1 and print colored( $1, $c );
            $2 and print colored( $2, "$c bold" );
            $3 and print colored( $3, $c );
        }
        else {
            print colored( $str, $c );
        }
        print "\n";
    }
    else {
        print "", join( '', @_ );
    }
}

sub p_debug(@) {
    $DEBUG and printc( C_DEBUG, P_DEBUG, @_ );
}

sub p_info(@) {
    $VERBOSE and printc( C_INFO, P_INFO, @_ );
}

sub p_warn(@) {
    printc( C_WARN, P_WARN, @_ );
}

sub p_error(@) {
    printc( C_ERROR, P_ERROR, @_ );
}

sub p_tell(@) {
    printc( C_TELL, P_TELL, @_ );
}

sub p_doing(@) {
    printc( C_DO, P_DO, @_ );
}

sub p_executing(@) {
    printc( C_EXEC, P_EXEC, @_ );
}

END {
}

1;
