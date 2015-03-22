#!/usr/bin/perl

use strict;
use warnings;

use FindBin;                 # locate this script
use lib "$FindBin::Bin/lib";  # use the parent directory
use PerlDots;

our $script_dir = getOption('script_dir') || "$FindBin::Bin/../scripts";


print getOption('verbose'), "\n";



