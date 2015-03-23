package PerlDots;

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Printing;

use Data::Dumper;
use Getopt::Long;
use Safe;

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(getOption setOption getTimestamp diffMinutes checkSyntax);
    our @EXPORT_OK = qw();
}

my %config = (
    verbose => '',
    config_filename => "$FindBin::Bin/.perldot",
    script_dir => "$FindBin::Bin/scripts",
    script_ext => 'perldot',
);

GetOptions(
    'verbose!'  => \$config{verbose},
    'debug!'    => \$config{debug}
);

$config{debug} and enableDebugOutput();
$config{verbose} and enableVerbose();

my $config_file;

if (-e $config{config_filename}) {
    if (checkSyntax($config{config_filename})) {
        (my $safe = new Safe())->permit_only();
        $config_file = $safe->rdo($config{config_filename});
        print Dumper($config_file);
        #p_info "Last run ", localtime($config_file->{lastrun}), "\n";
    }
    else {
        p_warn "corrupted config file, resetting persistent settings\n";
        unlink $config{config_filename}
            or p_error "Unable to delete '$config{config_filename}', please remove manually\n";
    }
}


sub getOption {
    my $var = shift;

    return $config{$var} || $config_file->{$var} || '';
}

sub setOption {
    my ($var, $val, $save) = @_;

    $config{$var} = $val;
    $save and $config_file->{$var} = $val;
}

sub getTimestamp {
    time;
}

sub diffTime {
    use integer;
    my $secs = (time - shift);
    my $mins = ($secs / 60) % 60;
    my $hours = ($secs / (60*60)) % (24);
    my $days = ($secs / (60*60*24));
    $secs = $secs % 60;

    return ($days, $hours, $mins, $secs);
}

sub checkSyntax {
    my $cmd = join(" ", $^X, '-c', shift);
    my $output = `$cmd 2>&1`;
    $? and p_error $output;
    return not($?);
}

END {
    if (open(my $cf, ">", $config{config_filename})) {
        $config_file->{lastrun} = getTimestamp();
        print $cf Data::Dumper->Dump([$config_file], [qw(config_file)]);

        close($cf)
            or p_error "close failed: $!";
    }
    else {
        p_error "cannot open > $config{config_filename}: $!";
    }
}

1;
