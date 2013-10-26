use strict;
use warnings;
use lib 't/lib/';
use TestUtils;
use TestMLBridge;

run_all_testml_files(
    "Real-world examples", 't/tml-world', \&test_yaml_perl
);
