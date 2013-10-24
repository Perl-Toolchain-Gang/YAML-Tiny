use strict;
use warnings;

BEGIN {
    $|  = 1;
    $^W = 1;
}

use t::lib::Test;
use YAML::Tiny;

use lib 't/lib';
use TestMLTiny;

sub main {
    testml_run_file(
        't/02_basic.tml',
        \&test_yaml,
    );
    done_testing;
}

sub test_yaml {
    my ($block) = @_;
    my ($label, $yaml, $perl, $noyamlpm) =
        @{$block}{qw(Label yaml perl noyamlpm)};
    $perl = eval $perl; die $@ if $@;
    my @flags = defined($noyamlpm) ? (noyamlpm => 1) : ();

    # Plain old tests (no subtests):
    yaml_ok($yaml, $perl, $label, @flags);

#     # For subtests, use this:
#     subtest "$block->{Label}", sub {
#         plan tests => 31;
#         yaml_ok($yaml, $perl, $label, @flags);
#     };
}

main @ARGV;
