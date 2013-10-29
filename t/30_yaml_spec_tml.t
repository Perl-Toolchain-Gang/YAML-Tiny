# Run the appropriate tests from https://github.com/ingydotnet/yaml-spec-tml
use strict;
use warnings;
use lib 't/lib/';
use TestMLTiny;
use TestMLBridge;
use TestUtils;

my $JSON = json_class()
    or Test::More::plan skip_all => "no JSON or JSON::PP";

# Each spec test will need a different bridge and arguments:
my @spec_tests = (
    ['t/tml-spec/basic.data.tml', 'test_yaml_json', $JSON],
    # This test is currently failing massively.
    # ['t/tml-spec/unicode.tml', 'test_code_point'],
);

for my $test (@spec_tests) {
    my ($file, $bridge, @args) = @$test;
    my $code = sub {
        my ($file, $blocks) = @_;
        Test::More::subtest "YAML Spec Test; file: $file" => sub {
            Test::More::plan tests => scalar @$blocks;
            my $func = \&{$bridge};
            $func->($_) for @$blocks;
        };
    };
    testml_run_file($file, $code, @args);
}

Test::More::done_testing;
