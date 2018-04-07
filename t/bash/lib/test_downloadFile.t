# vim: ft=perl
package test_downloadFile;

use warnings;
use strict;

use File::Temp qw/tempfile :seekable/;

use Test::More tests => 3;

my $script = $ENV{'DOTFILES'} . '/lib/downloadFile.sh';

sub runScript {
	my ($fh, $fn) = tempfile();
	print $fh @_;
	$fh->seek(0, SEEK_SET);

	my $output = `/usr/bin/env -i bash $fn 2> /dev/null`;
	return $output
}

sub okScript {
	my $cmd = shift;

	return <<EOF;
#!/usr/bin/env bash

PATH=''
source $script

if $cmd; then
	echo -n "ok"
else
	echo -n "fail"
fi

EOF
}

ok(runScript(okScript("downloadFile")) =~ m/fail$/);
ok(runScript(okScript("downloadFile url")) =~ m/fail$/);
ok(runScript(okScript("downloadFile url filename")) =~ m/curl.*wget.*fail$/s);
