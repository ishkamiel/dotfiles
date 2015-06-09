package Logging;

use strict;
use warnings;

use Term::ANSIColor;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA     = qw(Exporter);
    our @EXPORT =
      qw(p_debug p_info p_warn p_error p_tell);
    our @EXPORT_OK = qw();
}

use constant {
    P_DEBUG => "[DD] ",
    P_INFO  => "[II] ",
    P_WARN  => "[WW] ",
    P_ERROR => "[EE] ",
    P_TELL  => "[  ] ",
    C_DEBUG => 'white',
    C_INFO  => 'white',
    C_WARN  => 'magenta',
    C_ERROR => 'red',
    C_TELL  => 'bright_cyan',
};


sub printc {
    my $c = shift;

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

sub p_tellc($@) {
    printc( shift, P_TELL, @_ );
}

END {
}

1;
