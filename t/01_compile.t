#!/usr/bin/perl -w

# Load testing for YAML::Tiny

use strict;
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
}

use lib catdir('t', 'lib');
use Test::More tests => 3;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

# Does the module load
use_ok( 'YAML::Tiny' );
use_ok( 'MyTests'    );

exit(0);
