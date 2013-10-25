use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;
use TestMLTiny;

use YAML::Tiny;

# test a single file C<< perl -Ilib t/02_local_tml.t path/to/test.tml >>
sub main {
    my @files = scalar @ARGV ? @ARGV : testml_all_files('t/tml-local');
    for my $file ( @files ) {
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

main;
