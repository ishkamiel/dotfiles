package ScriptRunner;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use File::Find;
use Safe;

use PerlDots;
use Printing;

BEGIN {
    require Exporter;
    our $VERSION   = 0.01;
    our @ISA       = qw(Exporter);
    our @EXPORT    = qw(do_scripts);
    our @EXPORT_OK = qw();
}

sub findScriptFiles {
    my ( $e, @r ) = shift;

    find( ( sub { m/\.$e$/ and push @r, $File::Find::name; } ),
        getOption('script_dir') );

    return @r;
}

sub do_scripts {
    p_info "Looking for in ", getOption('script_dir'), "\n";

    foreach my $s ( findScriptFiles( getOption('script_ext') ) ) {
        p_debug "Processing script file '$s'\n";

        if ( checkSyntax($s) ) {
            foreach my $c ( do $s ) {
                p_debug "Calling execute_cmd(@$c)\n";
                execute_cmd(@$c);
            }
        }
        else {
            p_info "Found errors in ", $s, ", skipping\n";
        }
        p_debug "Done processing $s\n";
    }
}

sub waitingForTimed {
    my ($cmd, $opts) = @_;

    if ($opts->{timed}) {
        my $time = getOption($cmd, 'lastrun');

        if ($time) {
            my ($h, $m) = @{$opts->{timed}};
            $time = $time + ($m * 60) + ($h * 60 * 60) - time;

            if ($time > 0) {
                return diffTime( $time );
            }
        }
    }
    return;
}

sub execute_cmd {
    my $cmd  = shift;
    my $opts = shift;

    $opts->{timed}         ||= '';
    $opts->{ignore_retval} ||= '';

    if ( my $t = waitingForTimed( $cmd, $opts )) {
        p_tell "Skipping timed cmd (@$t left): ###$cmd###";
    }
    else {
        p_executing "Executing: ###$cmd###";
        setOption($cmd, 'lastrun', getTimestamp());
    }
}

END {
}

1;
