# Run the appropriate tests from https://github.com/ingydotnet/yaml-spec-tml
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;
use TestMLTiny;

use YAML::Tiny;

my $JSON = json_class()
    or plan skip_all => "no JSON or JSON::PP";

run_all_testml_files(
    't/tml-spec',
    sub { test_yaml_json("YAML::Tiny", $JSON, @_) },
    "YAML Spec Test File"
);

