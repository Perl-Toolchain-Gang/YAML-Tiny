use strict;
use warnings;
use lib 't/lib/';
use TestUtils;
use TestMLTiny;
use YAML::Tiny;

run_all_testml_files('t/tml-local', \&test_yaml_perl, "Implementation test");
