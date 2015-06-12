package PerlDots::Config;

use strict;
use warnings;

use Carp;

sub new {
    p_debug("entering Config::new");

    my $class = shift;
    my ($config_file, $data_file) = @_;

    my $self = {
        config_filename => $config_file,
        data_filename => $data_file,
        data => undef,
        config => undef,
        changes => 0,

    };
    bless($self);
}

sub DESTROY {
    p_debug("entering: Config->DESTROY");

    my $self = shift;

    if (changes > 0) {

        if ( open( my $cf, ">", $self->{filename} ) ) {
            print $cf Data::Dumper->Dump( [$self->{config}->{file}], [qw(config_file)] );

            close($cf) or p_error "close failed: $!";
        }
        else {
            p_error "cannot open > $config{config_filename}: $!";
        }
    }
}

sub read {
    my $self = shift;
    $self->_read_config;
    $self->_read_data;
}

sub _read_data {
    my $self = shift;

    croak ("unable to find config file: " + $self->{data_filename})
        unless -e $self->{data_filename};

    $self->{data} = do $self->{filename};
}

sub _read_config {
    my $self = shift,
}

sub set {
    my $self = shift;
    my ($var, $val) = @_;

    croak "Config not read" unless $self->{data};

    $self->{config}{file}{$var} = $val;
}

sub get {
    my $self = shift;
    my ($var, $default) = @_;

    croak "Config not read" unless $self->{data};

    return $self->{config}{file}{$var} || $default;
}

1;
