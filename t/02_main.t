#!/usr/bin/perl -w

# Main testing for YAML::Tiny

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

use Test::More tests => (3 * 6);
use YAML::Tiny;

# Do we have the authorative YAML to test against
eval { require YAML; }
my $COMPARE = !! $YAML::VERSION;

# 6 tests per call
sub parses_to {
	my $name   = shift;
	my $string = shift;
	my $parsed = shift;
	bless $parsed, 'YAML::Tiny';

	# Parse in the string
	my $yaml = YAML::Tiny->read_string( $string );
	isa_ok( $yaml, 'YAML::Tiny' );
	is_deeply( $yaml, $parsed, "$name: Parsed object matches expected" );

	# Round-trip the object
	my $output = $yaml->write_string;
	ok( (defined $output and ! ref $output),
		"$name: ->write_string writes a string" );
	my $yaml2 = YAML::Tiny->read_string( $output );
	isa_ok( $yaml2, 'YAML::Tiny' );
	is_deeply( $yaml, $yaml2, "$name: Perl->String->Perl round trip ok" );

	# If YAML itself is available, compare
	SKIP: {
		skip( "No YAML.pm to compare with", 2 ) unless $COMPARE;
		my @docs = eval { YAML::Load( $string ) };
		is( $@, '', "$name: YAML.pm loads the string ok" );
		is_deeply( \@docs, $expected, "$name: YAML.pm matches YAML::Tiny" );		
	}
}





#####################################################################
# Sample Testing

# Test a completely empty document
parses_to( empty => '', [  ] );

# Just a newline
parses_to( only_newline => "\n", [ ] );

# Just a comment
parses_to( only_comment => "# comment\n", [ ] );





#####################################################################
# Error Testing

exit(0);
