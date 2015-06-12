#!/usr/bin/perl
package PerlDots;

use strict;
use warnings;

use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/lib";

use Config;
use Logger;
use FileLinker;


our $VERBOSE = 0;
our $DEBUG = 0;
our @modules = ();

GetOptions(
    'verbose!' => \$VERBOSE,
    'debug!'   => \$DEBUG
);

# Initialize logger
my $l = PerlDots::Logger::getLogger();
$l->setLevel($PerlDots::Logger::LEVEL_INFO);
$VERBOSE and $l->setLevel($PerlDots::Logger::LEVEL{info});
$DEBUG and $l->setLevel($PerlDots::Logger::LEVEL{debug});

# Load config
#my $c = PerlDots::Config->new(DATA_FILE, CONFIG_FILE);

push @modules, PerlDots::FileLinker->new();

for my $m (@modules) {
    $m->init($l);
}

for my $m (@modules) {
    $m->run();
}
