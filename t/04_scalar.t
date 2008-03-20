#!/usr/bin/perl

# Testing of basic document structures

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use t::lib::Test;
use Test::More;
if ( t::lib::Test->have_yamlpm ) {
	plan( tests => 8 );
} else {
	plan( skip_all => 'Requites YAML.pm' );
	exit(0);
}

use YAML       ();
use YAML::Tiny ();





#####################################################################
# Sample documents

my $one = <<'END_YAML';
---
- foo
END_YAML

my $two = <<'END_YAML';
---
- foo
---
- bar
END_YAML





#####################################################################
# Match Listwise Behaviour

my $one_list_pm   = [ YAML::Load( $one ) ];
my $two_list_pm   = [ YAML::Load( $two ) ];
my $one_list_tiny = [ YAML::Tiny::Load( $one ) ];
my $two_list_tiny = [ YAML::Tiny::Load( $two ) ];

is_deeply( $one_list_pm, [ [ 'foo' ] ],  'one: Parsed correctly'     );
is_deeply( $one_list_pm, $one_list_tiny, 'one: List context matches' );

is_deeply( $two_list_pm, [ [ 'foo' ], [ 'bar' ] ], 'two: Parsed correctly'     );
is_deeply( $two_list_pm, $two_list_tiny,           'two: List context matches' );





#####################################################################
# Match Scalar Behaviour

my $one_scalar_pm   = YAML::Load( $one );
my $two_scalar_pm   = YAML::Load( $two );
my $one_scalar_tiny = YAML::Tiny::Load( $one );
my $two_scalar_tiny = YAML::Tiny::Load( $two );

is_deeply( $one_scalar_pm, [ 'foo' ],        'one: Parsed correctly'       );
is_deeply( $one_scalar_pm, $one_scalar_tiny, 'one: Scalar context matches' );

is_deeply( $two_scalar_pm, [ 'bar' ],        'two: Parsed correctly'       );
is_deeply( $two_scalar_pm, $two_scalar_tiny, 'two: Scalar context matches' );
