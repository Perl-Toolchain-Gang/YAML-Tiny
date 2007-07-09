#!/usr/bin/perl

# Testing of META.yml containing AVAR's name

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests(0, 1, 4);
use YAML::Tiny;





#####################################################################
# Testing that Perl::Smith config files work

my $sample_file = catfile( 't', 'data', 'multibyte.yml' );
my $sample      = load_ok( 'multibyte.yml', $sample_file, 450 );

# Does the string parse to the structure
my $name      = "multibyte";
my $yaml_copy = $sample;
my $yaml      = eval { YAML::Tiny->read_string( $yaml_copy ); };
is( $@, '', "$name: YAML::Tiny parses without error" );
is( $yaml_copy, $sample, "$name: YAML::Tiny does not modify the input string" );
SKIP: {
	skip( "Shortcutting after failure", 2 ) if $@;
	isa_ok( $yaml, 'YAML::Tiny' );
	is_deeply( $yaml->[0]->{build_requires}, {
		'Config'     => 0,
		'Test::More' => 0,
		'XSLoader'   => 0,
	}, 'build_requires ok' );
}

exit(0);
