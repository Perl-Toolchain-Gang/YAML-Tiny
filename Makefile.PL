use strict;
use inc::Module::Install;

name           'YAML-Tiny';
all_from       'lib/YAML/Tiny.pm';
build_requires 'File::Spec' => '0.80';
build_requires 'Test::More' => '0.47';

# Force compatibility tests during automated testing
if ( $ENV{AUTOMATED_TESTING} ) {
	build_requires 'YAML'       => '0.62';
	build_requires 'YAML::Syck' => '0.84';
}

WriteAll;
