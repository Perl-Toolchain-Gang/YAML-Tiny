#!/usr/bin/perl -w

# Testing of common META.yml examples

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
			catdir('blib', 'lib'),
			catdir('blib', 'arch'),
			'lib'
			);
	}
	lib->import( catdir('t', 'lib') );
}

use Test::More tests => (1 * 15);
use YAML::Tiny;
use MyTests 'yaml_ok';





#####################################################################
# Testing YAML::Tiny's own META.yml file

yaml_ok(
	<<'END_YAML',
abstract: Read/Write YAML files with as little code as possible
author: 'Adam Kennedy <cpan@ali.as>'
build_requires:
  File::Spec: 0.80
  Test::More: 0.47
distribution_type: module
generated_by: Module::Install version 0.63
license: perl
name: YAML-Tiny
no_index:
  directory:
    - inc
    - t
requires:
  perl: 5.005
version: 0.03
END_YAML
	[ {
		abstract          => 'Read/Write YAML files with as little code as possible',
		author            => 'Adam Kennedy <cpan@ali.as>',
		build_requires    => {
			'File::Spec' => '0.80',
			'Test::More' => '0.47',
		},
		distribution_type => 'module',
		generated_by      => 'Module::Install version 0.63',
		license           => 'perl',
		name              => 'YAML-Tiny',
		no_index          => {
			directory    => [ qw{inc t} ],
		},
		requires          => {
			perl         => '5.005',
		},
		version           => '0.03',
	} ],
	'YAML::Tiny',
);

exit(0);
