#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/lib";

use Logging;
use FileLinker;

our $VERBOSE = 0;
our $DEBUG = 0;

GetOptions(
    'verbose!' => \$VERBOSE,
    'debug!'   => \$DEBUG
);

p_tell "PerlDots";
p_info "Going verbose";
p_debug "Enabling debug output";

my $linker = FileLinker::new();
$linker->init();
$linker->run();
