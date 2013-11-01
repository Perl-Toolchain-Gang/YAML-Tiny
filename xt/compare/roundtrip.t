use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestBridge;
use xt::lib::Test;

use YAML::Tiny;

my $local_dir = "t/tml-local/yaml-roundtrip";
my $world_dir = "t/tml-world";

my @parsers = (
    (have_yamlpm()      ? "YAML"        : () ),
    (have_yamlxs()      ? "YAML::XS"    : () ),
    (have_yamlsyck()    ? "YAML::Syck"  : () ),
);

plan skip_all => "No other YAML parsers installed for comparison"
    unless @parsers;

my %skip_map = (
    'YAML' => 'noyamlpm',
    'YAML::XS' => 'noxs',
    'YAML::Syck' => 'nosyck',
);

my %loader_for = do {
    no strict 'refs';
    map {; $_ => *{$_ . "::Load"}{CODE} } "YAML::Tiny", @parsers;
};

my %dumper_for = do {
    no strict 'refs';
    map {; $_ => *{$_ . "::Dump"}{CODE} } "YAML::Tiny", @parsers;
};

for my $dir ( $local_dir, $world_dir ) {
    run_all_testml_files( "TestML", $dir, \&compare_roundtrip );
}

#--------------------------------------------------------------------------#
# compare_roundtrip
#
# two blocks: perl, yaml
#
# We compare behaviors for multiple parsers
#
# Tests that a YAML string loads to the expected perl data.  Also, tests
# roundtripping from perl->YAML->perl.
#
# We can't compare the YAML for roundtripping because YAML::Tiny doesn't
# preserve order and comments.  Therefore, all we can test is that given input
# YAML we can produce output YAML that produces the same Perl data as the
# input.
#
# The perl must be an array reference of data to serialize:
#
# [ $thing1, $thing2, ... ]
#
# However, if a test point called 'serializes' exists, the output YAML is
# expected to match the input YAML and will be checked for equality.
#--------------------------------------------------------------------------#

sub compare_roundtrip {
    my ($block) = @_;

    my ($yaml, $perl, $label) =
      _testml_has_points($block, qw(yaml perl)) or return;

    my %options = ();
    for (qw(serializes noxs nosyck noyamlpm)) {
        if (defined($block->{$_})) {
            $options{$_} = 1;
        }
    }

    my $expected = eval $perl; die $@ if $@;

    subtest $label, sub {
        
        my %perl_from;

        subtest "YAML to Perl" => sub {
            for my $p ( 'YAML::Tiny', @parsers ) {
                subtest $p => sub {
                    plan skip_all => "Not supported by $p"
                        if $p ne 'YAML::Tiny' && $options{$skip_map{$p}};

                    my $yaml_copy = $yaml;

                    ok(
                        $perl_from{$p} = [ eval { $loader_for{$p}->($yaml_copy) } ],
                        "Load with $p"
                    ) or diag "ERROR: " . _error_for($p);

                    return if $p eq 'YAML::Tiny'; # don't compare vs self

                    cmp_deeply(
                        $perl_from{"YAML::Tiny"},
                        $perl_from{$p},
                        "YAML::Tiny should match $p"
                    ) or diag "\nYAML:\n$yaml";
                }
            }

        };
    };
}

#--------------------------------------------------------------------------#
# _error_for -- normalize error handling
#--------------------------------------------------------------------------#

sub _error_for {
    my $p = shift;
    return $p eq 'YAML::Tiny' ? YAML::Tiny->errstr : $@;
}

done_testing;
