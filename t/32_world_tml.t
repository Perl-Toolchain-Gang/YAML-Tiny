use strict;
use warnings;
use lib 't/lib/';
use TestMLTiny;
use YAML::Tiny;

testml_run_all_files('t/tml-local', \&test_yaml_perl, "Real-world examples");
