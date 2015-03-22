package PerlDots;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Getopt::Long;

BEGIN {
    require Exporter;
    our $VERSION = 0.01;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(getOption func2);
    our @EXPORT_OK = qw($VERBOSE %Hashit func3);
}

my $CONFIG_FILE = $ENV{"HOME"} . "/.perldots/config"
my $HISTORY_FILE = $ENV{"HOME"} . "/.perldots/history"

if ( -e $ENV{"HOME"} . "/foo.txt" ) {
    print "yes ,it exists!" ;
}

my %config {
    verbose => '',
};

my $verbose = '';
GetOptions('verbose!' => \$config{verbose});

our $VERBOSE = $verbose;

sub getConfigFile {

}

sub getOption {
    my $var = shift;

    return $config{verbose}

    return 0;
}


#  # exported package globals go here
# our $Var1 = '';
# our %Hashit = ();
# # non-exported package globals go here
# # (they are still accessible as $Some::Module::stuff)
# our @more = ();
# our $stuff = '';
# # file-private lexicals go here, before any functions which use them
# my $priv_var = '';
# my %secret_hash = ();
# # here's a file-private function as a closure,
# # callable as $priv_func->();
# my $priv_func = sub {
# ...
# };
# # make all your functions, whether exported or not;
# # remember to put something interesting in the {} stubs
# sub func1 { ... }
# sub func2 { ... }
# # this one isn't exported, but could be called directly
# # as Some::Module::func3()
# sub func3 { ... }
#

END {
}

1;
