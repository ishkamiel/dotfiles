package PerlDots;

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Printing;

use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Getopt::Long;
use POSIX qw(strftime);

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA     = qw(Exporter);
    our @EXPORT  = qw(getOption setOption getTimestamp diffTime checkSyntax);
    our @EXPORT_OK = qw();
}

# Some default config stuff
my %config = (
    verbose         => 0,
    config_filename => "$FindBin::Bin/.perldot",
    script_dir      => "$FindBin::Bin/scripts",
    script_ext      => 'perldot',
);

GetOptions(
    'verbose!' => \$config{verbose},
    'debug!'   => \$config{debug}
);

$config{debug}   and enableDebugOutput();
$config{verbose} and enableVerbose();

my $prev_config;
my $save_config = { lastrun => getTimestamp() };

if ( -e $config{config_filename} ) {
    if ( checkSyntax( $config{config_filename} ) ) {
        $prev_config = do $config{config_filename};
        p_info "Last run: ", getLastrun(), "\n";
    }
    else {
        p_warn "corrupted config file, resetting persistent settings\n";
        unlink $config{config_filename}
          or p_error
"Unable to delete '$config{config_filename}', please remove manually\n";
    }
}

sub getOption {
    my $var = shift;

    if ( $prev_config->{$var} and not( $save_config->{$var} ) ) {
        $save_config->{$var} = $prev_config->{$var};
    }

    return $config{$var} || $save_config->{$var} || '';
}

sub setOption {
    my ( $var, $val ) = @_;

    $config{$var} = $val;
    $save_config->{$var} = $val;
}

sub getTimestamp {
    time;
}

sub getLastrun {
    $prev_config or return '';

    return strftime "%Y-%m-%d %H:%M:%S", localtime( $prev_config->{lastrun} );
}

sub diffTime {
    use integer;
    my $secs  = shift;
    my $mins  = ( $secs / 60 ) % 60;
    my $hours = ( $secs / ( 60 * 60 ) ) % (24);
    my $days  = ( $secs / ( 60 * 60 * 24 ) );
    $secs = $secs % 60;

    return [ $days, $hours, $mins, $secs ];
}

sub checkSyntax {
    my $cmd = join( " ", $^X, '-c', '-w', shift );
    my $output = `$cmd 2>&1`;
    $? and p_error $output;
    return not($?);
}

END {
    if ( open( my $cf, ">", $config{config_filename} ) ) {
        print $cf Data::Dumper->Dump( [$save_config], [qw(config_file)] );

        close($cf)
            or p_error "close failed: $!";
    }
    else {
        p_error "cannot open > $config{config_filename}: $!";
    }
}

1;
