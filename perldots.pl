#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use PerlDots;
use ScriptRunner;
use FileLinker;

my $linker = FileLinker::new();
$linker->init();
$linker->run();

do_scripts();
