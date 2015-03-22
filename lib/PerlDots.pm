package PerlDots;

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Printing;

use Getopt::Long;

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(getOption);
    our @EXPORT_OK = qw();
}

# core module...
# our $have_getopt = eval {
#     require Getopt::Long;
#     Getopt::Long->import();
#     1;
# };
#
# $have_getopt or p_warn("Install Getopt::Long to use cmd line args\n");

my %config = (
    verbose => '',
    config_file => $ENV{"HOME"} . "/.perldots/config",
    history_file => $ENV{"HOME"} . "/.perldots/history",
    script_dir => "$FindBin::Bin/scripts",
    script_ext => 'perldot',
);

GetOptions(
    'verbose!'  => \$config{verbose},
    'debug!'    => \$config{debug}
);

$config{debug} and enableDebugOutput();
$config{verbose} and enableVerbose();

sub getOption {
    my $var = shift;

    return $config{$var} || "";
}


END {
}

1;
