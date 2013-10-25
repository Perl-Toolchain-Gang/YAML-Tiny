# Load testing for YAML::Tiny

use strict;
use warnings;

BEGIN {
    $|  = 1;
    $^W = 1;
}

use File::Spec::Functions ':ALL';
use Test::More 0.90;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

# Does the module load
use_ok( 'YAML::Tiny'   );
use_ok( 't::lib::Test' );

done_testing;
