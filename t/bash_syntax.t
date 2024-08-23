# vim: ft=perl
#
# Author Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
package bash_syntax;

use warnings;
use strict;

use File::Temp qw/tempfile :seekable/;
use File::Find;
use Test::More tests => 7;

our $test_bin = "/bin/bash";
our $test_cmd = qq|$test_bin -n %s 2>&1|;

our $test_file_dirs_match = qr/\.(sh|bash)$/;
our @test_file_dirs = (
    "$ENV{'DOTFILES'}/lib/themes",
    "$ENV{'DOTFILES'}/scripts",
);

our @test_files = (
    "$ENV{'DOTFILES'}/lib/downloadFile.sh",
    "$ENV{'DOTFILES'}/lib/debug.sh",
    "$ENV{'DOTFILES'}/lib/checks.sh",
    "$ENV{'DOTFILES'}/.bashrc"
);

sub echo { printf(qq|%s: %s\n|, scalar((caller(1))[3]),  @_); }

sub test_bash_syntax {
    my $fn = shift;
    my $silent = shift;

    my $cmd = sprintf($test_cmd, $fn);

    echo "executing: '$cmd'";
    my $result = `$cmd`;
    die("could not execute'$cmd'\n") if !defined($result);
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

sub check_one {
    my $file = shift;
    echo "testing $file";
    return test_bash_syntax($file);
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
for (@test_file_dirs) {
    ok(check_all($_, $test_file_dirs_match));
}

for (@test_files) {
    ok((! -e "$_") or check_one($_));
}
