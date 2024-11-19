#!/usr/bin/perl

use strict;
use warnings;

# Get and validate command line arguments
if (!@ARGV) { print "No command given\n";
    print "Usage: shutup servername\n";
    exit(-1);
}

my $server_name = $ARGV[0];
my $ssh_commands = "";
if ($ARGV[1]) {
    $ssh_commands = $ARGV[1];
}

if ($ssh_commands) {
    $ssh_commands =~ s/"/\\"/g;
}

if (!($server_name =~ /[a-zA-Z]+/)) {
    print "Invalid server name: ${server_name}\n";
    exit(-1);
}

# Search for the config files and read the first one to be found
my %config = (
    "PEM_PATH" => "./"
);

my @CONFIG_FILE_PATHS = (
    ".shutup.gpg",
    $ENV{"HOME"} . "/.shutup.gpg"
);

my $config_content;

foreach (@CONFIG_FILE_PATHS) {
    print $_, "\n";
    next if !-e;

    my $target_filename = $_;
    $target_filename =~ s/.gpg//;

    #$config_cnotent = system("gpg -o $target_filename --decrypt $_") == 0 or die "Could not decrypt config file";
    $config_content = `gpg --decrypt $_`;
    if (!$config_content) {
        die "Could not decrypt config file";
    }
 
    open(FH, "<", $target_filename) or next;

    do { local $/; $config_content = <FH> };

    unlink($target_filename);
}

if (!$config_content) {
    print "No config file found\n";
    print "Possible locations are: " . join(", ", @CONFIG_FILE_PATHS) . "\n";
    exit(-1);
}

my @configs_in_file = $config_content =~ /^(.*=.*)$/gm;

foreach (@configs_in_file) {
    my ($config_key, $config_val) = /^(.*)(?:\s+)=(?:\s+)(.*)$/ or die "Invalid config near $_\n";

    exists $config{$config_key} or die "Invalid config key: ${config_key}\n";

    $config{$config_key} = $config_val;
}

# Cleanup/validate configs
$config{"PEM_PATH"} =~ s/\/$//;

# Search for the server name in the config file content
my ($server_config_str) = $config_content =~ /^($server_name\s.*)/m;
if (!$server_config_str) {
    print "No config found for server name: $server_name\n";
    exit(-1);
}


my $server_config_regex = qr/^$server_name\s+([^\s]+)\s+([^\s]+)$/m;
my ($host, $password_or_pem) = $server_config_str =~ $server_config_regex or die "Invalid configuration near $server_config_str\n";


if ($password_or_pem =~ /\.pem$/) {
    my @args;
    push @args, $host;

    push @args, "-i";

    if ($password_or_pem =~ /^\/.*/) {
        push @args, $password_or_pem;
    } else {
        my $fullpath = $config{"PEM_PATH"} . "/" . $password_or_pem;
        push @args, $fullpath;
    }

    my $args_str = join " ", @args;
    exec("ssh $args_str \"$ssh_commands\"");
} else {
    exec("sshpass -p ${password_or_pem} ssh ${host} \"${ssh_commands}\"");
}

