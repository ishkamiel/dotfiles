package FileLinker;

use strict;
use warnings;

use Logging;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);


BEGIN {
    require Exporter;
    our $VERSION   = 0.01;
    our @ISA       = qw(Exporter);
    our @EXPORT    = qw();
    our @EXPORT_OK = qw();
}

sub new {
    my $self = {};
    bless($self);
}

sub init {
    my $self = shift;
    my $config = shift;
    p_debug("FileLinkier initialized");
}

sub run {
    my $self = shift;
    p_debug("FileLinker running");
    return 1;
}

1;
