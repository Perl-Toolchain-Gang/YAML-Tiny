# Testing documents that should fail
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;

use File::Spec::Functions ':ALL';
use YAML::Tiny ();


# tests for read_string()
{
    eval { YAML::Tiny->read_string(); };
    like(YAML::Tiny->errstr, qr/Did not provide a string to load/,
        "Got expected error: no string provided to read_string()");
    $YAML::Tiny::errstr = '';
}

{
    my $str = join("\n" => ('---', '- foo', '---', '- bar', '---'));
    eval { YAML::Tiny->read_string($str); };
    like(YAML::Tiny->errstr, qr/Stream does not end with newline character/,
        "Got expected error: stream did not end with newline");
    $YAML::Tiny::errstr = '';
}

done_testing;
