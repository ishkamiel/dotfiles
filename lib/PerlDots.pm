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
    our @EXPORT = qw(getOption setOption getTimestamp diffMinutes);
    our @EXPORT_OK = qw();
}

my $have_config = eval {
    require Config::Simple;
    Config::Simple->import();
    1;
};

$have_config or p_warn("Please install Config::Simple to enable persistent config and history\n");


my %config = (
    verbose => '',
    config_file => $ENV{"HOME"} . "/.perldots",
    script_dir => "$FindBin::Bin/scripts",
    script_ext => 'perldot',
);

my $config_file;

if ($have_config) {
    $config_file = new Config::Simple(
        filename => $config{config_file},
        syntax => 'ini',
        autosave => 'autosave');
}

GetOptions(
    'verbose!'  => \$config{verbose},
    'debug!'    => \$config{debug}
);

$config{debug} and enableDebugOutput();
$config{verbose} and enableVerbose();

sub getOption {
    my $var = shift;

    $config{$var} and return $config{$var};

    if ($config_file and my $r = $config_file->param($var)) {
        return $r;
    }

    return '';
}

sub setOption {
    my ($var, $val) = @_;

    $config{$var} = $val;

    if ($have_config) {
        $config_file->param($var => $val);
    }
    else {
        p_info "Persistent config not supported";
    }
}

sub getTimestamp {
    time;
}

sub diffMinutes {
    use integer;
    return ((time - shift)/60);
}

END {
}

1;
