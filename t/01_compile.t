#!/usr/bin/perl -w

# Load testing for YAML::Tiny

# This test only tests that the module compiles.

use strict;
use Test::More tests => 2;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

# Does the module load
use_ok( 'YAML::Tiny' );

exit(0);
