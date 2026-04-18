#!/usr/bin/perl
# This script is based on askubuntu.com answer by Stephen Ostermiller:
#
# https://askubuntu.com/questions/26056/where-are-gnome-keyboard-shortcuts-stored/217310

use warnings;
use strict;

# Run a command, warning with the actual exit code (or exec error) on failure.
sub _run {
    my @cmd = @_;
    my $rc = system(@cmd);
    if ($rc == -1) {
        warn "failed to exec @cmd: $!";
    } elsif ($rc & 127) {
        warn sprintf('%s died with signal %d', "@cmd", $rc & 127);
    } elsif ($rc >> 8) {
        warn sprintf('%s exited with status %d', "@cmd", $rc >> 8);
    }
}

# Close a pipe and die loudly if the child failed; partial exports are worse than none.
sub _close_pipe {
    my ($fh, $what) = @_;
    return if close($fh);
    die sprintf('%s failed (exit %d): %s', $what, $? >> 8, $! || 'pipe close error');
}

my $action = '';
my $filename = '-';

for my $arg (@ARGV){
    if ($arg eq "-e" or $arg eq "--export"){
        $action = 'export';
    } elsif ($arg eq "-i" or $arg eq "--import"){
        $action = 'import';
    } elsif ($arg eq "-h" or $arg eq "--help"){
        print "Import and export keybindings\n";
        print " -e, --export <filename>\n";
        print " -i, --import <filename>\n";
        print " -h, --help\n";
        exit;
    } elsif ($arg =~ /^\-/){
        die "Unknown argument $arg";
    } else {
        $filename = $arg;
        if (!$action){
            if ( -e $filename){
                $action='import';
            } else {
                $action='export';
            }
        }
    }
}

$action='export' if (!$action);
if ($action eq 'export'){
    &export();
} else {
    &import();
}

sub export(){
    my $gsettingsFolders = [
        ['org.gnome.desktop.wm.keybindings','.'],
        ['org.gnome.settings-daemon.plugins.power','button'],
        ['org.gnome.settings-daemon.plugins.media-keys','.'],
    ];

    my $customBindings = [
    ];

    $filename = ">$filename";
    open (my $fh, $filename) || die "Can't open file $filename: $!";

    for my $folder (@$gsettingsFolders){
        open(my $lsfh, '-|', 'gsettings', 'list-recursively', $folder->[0])
            or die "Can't run gsettings: $!";
        my @keylist = <$lsfh>;
        _close_pipe($lsfh, "gsettings list-recursively $folder->[0]");
        chomp @keylist;
        foreach my $line (@keylist){
            if ($line =~ /^([^ ]+) ([^ ]+)(?: \@[a-z]+)? (.*)/){
                my ($path, $name, $value) = ($1,$2,$3);
                if ($name eq "custom-keybindings"){
                    $value =~ s/[\[\]\' ]//g;
                    my @c = split(/,/, $value);
                    $customBindings = \@c;
                } elsif ($name =~ /$folder->[1]/){
                    if ($value =~ /^\[|\'/){
                        if ($value =~ /^\[\'(?:disabled)?\'\]$/){
                            $value = '[]';
                        }
                        print $fh "$path\t$name\t$value\n";
                    }
                }
            } else {
                die "Could not parse $line";
            }
        }
    }

    for my $folder (@$customBindings){
        my $schema = "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$folder";
        open(my $gsfh, '-|', 'gsettings', 'list-recursively', $schema)
            or die "Can't run gsettings: $!";
        my $gs = do { local $/; <$gsfh> };
        _close_pipe($gsfh, "gsettings list-recursively $schema");
        my ($binding) = $gs =~ /custom-keybinding binding (\'[^\n]+\')/g;
        my ($command) = $gs =~ /custom-keybinding command (\'[^\n]+\')/g;
        my ($name)    = $gs =~ /custom-keybinding name (\'[^\n]+\')/g;
        $binding or $binding = q|''|;
        print $fh "custom\t$name\t$command\t$binding\n";
    }

    close($fh);
}

sub import(){

    $filename = "<$filename";
    open (my $fh, $filename) || die "Can't open file $filename: $!";

    my $customcount=0;

    while (my $line = <$fh>){
        chomp $line;
        if ($line){
            my @v = split(/\t/, $line);
            if ($v[0] eq 'custom'){
                my ($custom, $name, $command, $binding) = @v;
                print "Installing custom keybinding: $name\n";
                my $schema = "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"
                    . "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$customcount/";
                _run('gsettings', 'set', $schema, 'name',    $name);
                _run('gsettings', 'set', $schema, 'command', $command);
                _run('gsettings', 'set', $schema, 'binding', $binding);
                $customcount++;
            } else {
                my ($path, $name, $value) = @v;
                print "Importing $path $name\n";
                _run('gsettings', 'set', $path, $name, $value);
            }
        }
    }
    if ($customcount > 0){
        my $customlist = "";
        for (my $i=0; $i<$customcount; $i++){
            $customlist .= "," if ($customlist);
            $customlist .= "'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/'";
        }
        $customlist = "[$customlist]";
        print "Importing list of custom keybindings.\n";
        _run('gsettings', 'set',
             'org.gnome.settings-daemon.plugins.media-keys',
             'custom-keybindings', $customlist);
    }

    close($fh);
}
