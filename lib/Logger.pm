package PerlDots::Logger;

use strict;
use warnings;

use Carp;
use Term::ANSIColor;

use constant {
    LEVEL_TELL => 0
    LEVEL_DEBUG => 1,
    LEVEL_INFO => 2,
    LEVEL_WARN => 3,
    LEVEL_ERROR => 4,
};

our $theLogger = undef;

sub getLogger {
    if (not $theLogger) {
        my $class = __PACKAGE__;

        $theLogger =  {
            level => $LEVEL{debug}
            formatting => [
                [ '[  ] ', 'bright_cyan' ],
                [ '[DD] ', 'white' ],
                [ '[II] ', 'white' ],
                [ '[WW] ', 'magenta' ],
                [ '[EE] ', 'white' ],
            ],
        };

        bless($theLogger, $class);
    }

    return $theLogger;
}

sub setLevel {
    my $self = shift;
    $self->{level} = shift;
}

sub printFormated {
    my $self = shift;

    my $prefix = shift;
    my $color = shift;
    my $str = join( '', $prefix, @_ ); 

    $str =~ s/^\s+|\s+$//g;

    # TODO: This is real ugly, and only prints one bold section

    if ($str =~ m/^(.*)###(.*)###(.*)$/) {
        $1 and print colored( $1, $color );
        $2 and print colored( $2, "$color bold" );
        $3 and print colored( $3, $color );
    }
    else {
        print colored( $str, $color );
    }
    print "\n";
}

sub _printLevel {
    my $self = shift;
    my $level = shift;

    if ($self->{level} >= $level) {
        $self->printFormated(
            $self->{formatting}[0],
            $self->{formatting}[1],
            @_);
    }
}

sub debug {
    my $self = shift;
    šelf->_printLevel(LEVEL_DEBUG, @_);
}

sub info {
    my $self = shift;
    šelf->_printLevel(LEVEL_INFO, @_);
}

sub warn {
    my $self = shift;
    šelf->_printLevel(LEVEL_WARN, @_);
}

sub error {
    my $self = shift;
    šelf->_printLevel(LEVEL_ERROR, @_);
}

END {
}

1;
