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
use Test::More tests(6);
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






#####################################################################
# Testing various failing META.yml files from CPAN

yaml_ok(
	<<'END_YAML',
---
abstract: Mii in Nintendo Wii data parser and builder
author: Toru Yamaguchi <zigorou@cpan.org>
distribution_type: module
generated_by: Module::Install version 0.65
license: perl
meta-spec:
  url: http://module-build.sourceforge.net/META-spec-v1.3.html
  version: 1.3
name: Games-Nintendo-Wii-Mii
no_index:
  directory:
    - inc
    - t
requires:
  Carp: 1.03
  Class::Accessor::Fast: 0.3
  File::Slurp: 9999.12
  IO::File: 1.1
  Readonly: 0
  Tie::IxHash: 1.21
  URI: 1.35
  XML::LibXML: 1.62
version: 0.02
END_YAML
	[ {
		abstract => 'Mii in Nintendo Wii data parser and builder',
		author   => 'Toru Yamaguchi <zigorou@cpan.org>',
		distribution_type => 'module',
		generated_by => 'Module::Install version 0.65',
		license => 'perl',
		'meta-spec' => {
			url => 'http://module-build.sourceforge.net/META-spec-v1.3.html',
			version => '1.3',
		},
		name => 'Games-Nintendo-Wii-Mii',
		no_index => {
			directory => [ qw{ inc t } ],
		},
		requires => {
			'Carp' => '1.03',
			'Class::Accessor::Fast' => '0.3',
			'File::Slurp' => '9999.12',
			'IO::File'    => '1.1',
			'Readonly'    => '0',
			'Tie::IxHash' => '1.21',
			'URI'         => '1.35',
			'XML::LibXML' => '1.62',
		},
		version => '0.02',
	} ],
	'Games-Nintendo-Wii-Mii',
);

yaml_ok(
	<<'END_YAML',
# http://module-build.sourceforge.net/META-spec.html
#XXXXXXX This is a prototype!!!  It will change in the future!!! XXXXX#
name:         Acme-Time-Baby
version:      2.106
version_from: Baby.pm
installdirs:  site
requires:
    warnings:

distribution_type: module
generated_by: ExtUtils::MakeMaker version 6.17
END_YAML
	[ {
		name => 'Acme-Time-Baby',
		version => '2.106',
		version_from => 'Baby.pm',
		installdirs => 'site',
		requires => {
			warnings => undef,
		},
		distribution_type => 'module',
		generated_by => 'ExtUtils::MakeMaker version 6.17',
	} ],
	'Acme-Time-Baby',
);





#####################################################################
# File with a YAML header

yaml_ok(
	<<'END_YAML',
--- %YAML:1.0
name:     Data-Swap
version:  0.05
license:  perl
distribution_type: module
requires:
   perl:  5.6.0
dynamic_config: 0
END_YAML
	[ {
		name => 'Data-Swap',
		version => '0.05',
		license => 'perl',
		distribution_type => 'module',
		requires => {
			perl => '5.6.0',
		},
		dynamic_config => '0',
	} ],
	'Data-Swap',
	noyaml => 1,
);

yaml_ok(
	<<'END_YAML',
--- #YAML:1.0
name:     Data-Swap
version:  0.05
license:  perl
distribution_type: module
requires:
   perl:  5.6.0
dynamic_config: 0
END_YAML
	[ {
		name => 'Data-Swap',
		version => '0.05',
		license => 'perl',
		distribution_type => 'module',
		requires => {
			perl => '5.6.0',
		},
		dynamic_config => '0',
	} ],
	'Data-Swap',
	nosyck => 1,
);

exit(0);
