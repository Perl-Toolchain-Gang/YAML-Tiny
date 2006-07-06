#!/usr/bin/perl -w

# Load testing for YAML::Tiny

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import(
			catdir( 'blib', 'lib' ),
			catdir( 'blib', 'arch' ),
			'lib'
			);
	}
}

use Test::More tests => 2;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

# Does the module load
use_ok( 'YAML::Tiny' );

exit(0);
