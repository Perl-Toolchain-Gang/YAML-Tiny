#!/usr/bin/perl -w

# Testing of common META.yml examples

use strict;
use File::Spec::Functions ':ALL';
BEGIN {
	$|  = 1;
	$^W = 1;
}

use lib catdir('t', 'lib');
use MyTests;
use Test::More tests(2);
use YAML::Tiny;





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






#####################################################################
# Testing a META.yml from a commercial project that crashed

yaml_ok(
	<<'END_YAML',
# http://module-build.sourceforge.net/META-spec.html
#XXXXXXX This is a prototype!!!  It will change in the future!!! XXXXX#
name:         ITS-SIN-FIDS-Content-XML
version:      0.01
version_from: lib/ITS/SIN/FIDS/Content/XML.pm
installdirs:  site
requires:
    Test::More:                    0.45
    XML::Simple:                   2

distribution_type: module
generated_by: ExtUtils::MakeMaker version 6.30
END_YAML
	[ {
		name              => 'ITS-SIN-FIDS-Content-XML',
		version           => 0.01,
		version_from      => 'lib/ITS/SIN/FIDS/Content/XML.pm',
		installdirs       => 'site',
		requires          => {
			'Test::More'  => 0.45,
			'XML::Simple' => 2,
			},
		distribution_type => 'module',
		generated_by      => 'ExtUtils::MakeMaker version 6.30',
	} ],
	'YAML::Tiny',
);

exit(0);
