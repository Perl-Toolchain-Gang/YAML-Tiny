# Load testing for YAML::Tiny

use strict;
use warnings;
use lib 't/lib';

BEGIN {
    $|  = 1;
}

use Test::More 0.99;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

# Does the module load
require_ok( 'YAML::Tiny' );
require_ok( 'TestUtils' );
require_ok( 'TestMLTiny' );

done_testing;
