package Config;

use strict;
use warnings;

use Printing;

sub new {
    p_debug("entering Config::new");

    my $class = shift;
    my ($filename) = @_;

    my $self = {
        filename


    my $self = {
        filename => $filename,
        changes => 0,
        read_ok => 0,
    };
    bless($self);
}

sub DESTROY {
    p_debug("entering: Config->DESTROY");

    my $self = shift;

    if (changes > 0) {

        if ( open( my $cf, ">", $self->{filename} ) ) {
            print $cf Data::Dumper->Dump( [$self->{config}->{file}], [qw(config_file)] );

            close($cf) or p_error "close failed: $!";
        }
        else {
            p_error "cannot open > $config{config_filename}: $!";
        }
    }
}

sub read {
    p_debug("entering: Config->read");

    my $self = shift;

    if (not -e $self->{filename} ) {
        p_warn("unable to find config file: " + $self->{filename});
        return 0;
    }

    # if (not checkSyntax( $config{config_filename} ) ) {
    #     p_warn "corrupted config file, resetting persistent settings\n";
    #     return 0;
    # }

    $self->{config}->{file} = do $self->{filename};
    p_info("Successfully read config from " + $self->{filename});
    $self->{read_ok} = 1;
}

sub set {
    p_debug("entering: Config->set");
    
    my $self = shift;
    my ($var, $val) = @_;

    $self->{read_ok} || die "Config->set called before successfull read";

    $self->{config}{file}{$var} = $val;
}

sub get {
    pd_debug("entering: Config->get");
    
    my $self = shift;
    my ($var, $default) = @_;

    $self->{read_ok} || die "Config->get called before successfull read";

    return $self->{config}{file}{$var} || $default;
}

# sub checkSyntax {
#     my $cmd = join( " ", $^X, '-c', '-w', shift );
#     my $output = `$cmd 2>&1`;
#     $? and p_error $output;
#     return not($?);
# }

1;
