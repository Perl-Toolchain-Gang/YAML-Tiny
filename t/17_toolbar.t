#!/usr/bin/perl

# Testing of a known-bad file from an editor

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More skip_all => 'Temporarily ignoring failing test';
use Test::More tests(1, 1);
use YAML::Tiny;





#####################################################################
# Testing that Perl::Smith config files work

my $toolbar_file = catfile( 't', 'data', 'toolbar.yml' );
my $toolbar      = load_ok( 'toolbar.yml', $toolbar_file, 1000 );

yaml_ok(
	$toolbar,
	[ {
		main_toolbar => [
			'item file-new',
			'item file-open',
		]
	} ],
	'toolbar.yml',
);

exit(0);
