# Run the appropriate tests from https://github.com/ingydotnet/yaml-spec-tml
use strict;
use warnings;
use lib 't/lib/';
use TestUtils;
use TestMLBridge;

my $JSON = json_class()
    or plan skip_all => "no JSON or JSON::PP";

run_all_testml_files(
    "YAML Spec Test File", 't/tml-spec', \&test_yaml_json,
    $JSON, 'YAML::Tiny',
);

