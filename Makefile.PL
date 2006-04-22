use inc::Module::Install;

name           'YAML-Tiny';
all_from       'lib/YAML/Tiny.pm';
build_requires 'Test::More' => '0.47';

auto_install;
WriteAll;
