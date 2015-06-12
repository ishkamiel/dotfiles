package PerlDots::FileLinker;

use strict;
use warnings;

use Logger;

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    return bless {}, $class;
}

sub init {
    my $self = shift;
    my ($logger) = @_;
    my $config = shift;

    $self->{l} = $logger;
    $self->{l}->debug("FileLinkier initialized");
}

sub run {
    my $self = shift;
    $self->{l}->debug("FileLinker running");
    return 1;
}

1;
