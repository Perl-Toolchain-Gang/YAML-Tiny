use strict;
use warnings;
use lib 't/lib/';
use TestUtils;
use TestMLBridge;

run_all_testml_files(
    "Implementation test", 't/tml-local', \&test_yaml_perl
);
