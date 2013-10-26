package TestMLRun;

use strict;
use warnings;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{ run_testml_files };

use Test::More 0.99;
use TestMLTiny;
use TestUtils;

use YAML::Tiny;

sub run_testml_files {
    for my $file ( @_ ) {
        note "YAML Spec Test File: $file";
        testml_run_file($file, \&test_yaml_perl);
    }
    done_testing;
}

sub test_yaml_perl {
    my ($block) = @_;
    my ($label, $yaml, $perl) =
        @{$block}{qw(Label yaml perl)};
    $perl = eval $perl; die $@ if $@;
    my %flags = ();
    for (qw(serializes)) {
        if (defined($block->{$_})) {
            $flags{$_} = 1;
        }
    }

    subtest "$block->{Label}", sub {
        yaml_ok($yaml, $perl, $label, %flags);
    };
}

1;
