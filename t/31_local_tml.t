use strict;
use warnings;
use lib 't/lib/';
use TestUtils;
use TestBridge;

run_all_testml_files(
    "Implementation test", 't/tml-local', \&test_local
);
