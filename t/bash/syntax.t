# vim: ft=perl
#
# Author Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
package test_syntax;

use warnings;
use strict;

use File::Temp qw/tempfile :seekable/;
use File::Find;
use Test::More tests => 3;

our $bash_bin = "/bin/bash";

our $bash_lib_dir = $ENV{'DOTFILES_BASH'};
our $script_dir = "$ENV{'DOTFILES'}/scripts";

sub echo { print scalar((caller(1))[3]), ": ", @_, "\n"; }

sub test_bash_syntax {
    my $fn = shift;
    my $silent = shift;

    my $cmd = qq|$bash_bin -n $fn 2>&1|;

    echo "executing: `$cmd`";
    my $result = `$cmd`;
    die("could not execute blastall: $cmd\n") if !defined($result);
    die("$cmd died from signal ", ($? & 127), "\n") if $? & 127;
    if ($? >> 8) {
        echo "syntax check failed";
        print STDERR $result unless $silent;
        return;
    }
    return 1;
}

sub sanity_check {
    # Sanity check that we actually fail on bad syntax!
    my ($fh, $fn) = tempfile() or die "failed to create tmpfile";
    print $fh "\nif [[[ -e then echo yay; fi\n";
    close($fh) or die "failed to close $fn";

    echo "testing dummy file at $fn";

    # We are expecting this to fail!
    my $retval = !test_bash_syntax($fn, "silent");

    echo "cleaning up and returning $retval";
    unlink($fn) or die "failex to remove tmp file $fn";
    return $retval;
}

sub check_all {
    my $path = shift;
    my $match = shift;
    my $fails = 0;

    echo "looking into $path";
    find((sub {
                return unless -T;
                if (!defined($match) or m/$match/) {
                    echo "testing ${File::Find::name}";
                    $fails++ unless test_bash_syntax(${File::Find::name});
                }
            }), $path);

    return !$fails;
}

ok(sanity_check());
ok(check_all($bash_lib_dir, qr/\.sh$/));
ok(check_all($script_dir, qr/\.sh$/));

#ok(runScript(okScript("downloadFile url")) =~ m/fail$/);
#ok(runScript(okScript("downloadFile url filename")) =~ m/curl.*wget.*fail$/s);
