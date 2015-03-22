package Printing;

use strict;
use warnings;
use Exporter;
use File::Find;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(p_debug p_info p_warn p_error p_tell p_doing p_executing enableVerbose enableDebugOutput);
    our @EXPORT_OK = qw();
}

use Term::ANSIColor;

my $have_ansicolor = 1;
# This is a core module, so should always be present, I think?
# my $have_ansicolor = eval {
#     require Term::ANSIColor;
#     Term::ANSIColor->import();
#     1;
# };

$have_ansicolor or print("Install Term::ANSIColor for nice color output\n");

my $C_DEBUG = 'white faint';
my $C_INFO = 'white';
my $C_WARN = 'red';
my $C_ERROR = 'bright_red';
my $C_TELL = 'cyan';
my $C_DOING = 'blue';
my $C_EXECUTING = 'magenta';

my $DEBUG = '';
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
        print colored(join('', @_), $c);
    }
    else {
        print "", join('', @_);
    }
}

sub p_debug(@) {
    $DEBUG and printc($C_DEBUG, @_);
}

sub p_info(@) {
    $VERBOSE and printc($C_INFO, @_);
}

sub p_warn(@) {
    printc($C_WARN, @_);
}

sub p_error(@) {
    printc($C_ERROR, @_);
}

sub p_tell(@) {
    printc($C_TELL, @_);
}

sub p_doing(@) {
    printc($C_DOING, @_);
}

sub p_executing(@) {
    printc($C_EXECUTING, @_);
}

END {
}

1;
