use inc::Module::Install;

name           'YAML-Tiny';
all_from       'lib/YAML/Tiny.pm';
build_requires 'Test::More' => '0.47';

# During automated testing, force comparative testing
if ( $ENV{AUTOMATED_TESTING} ) {
	build_requires 'YAML' => 0;
}

auto_install;
WriteAll;
