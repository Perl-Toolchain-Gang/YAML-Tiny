# Testing documents that should fail
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;

use File::Spec::Functions ':ALL';
use YAML::Tiny ();


# tests for read()
{
    eval { YAML::Tiny->read(); };
    like(YAML::Tiny->errstr, qr/You did not specify a file name/,
        "Got expected error: no filename provided to read()");
    $YAML::Tiny::errstr = '';
}

{
    my $file = catfile( test_data_directory(), 'nonexistent.yml' );
    eval { YAML::Tiny->read($file); };
    like(YAML::Tiny->errstr, qr/File '$file' does not exist/,
        "Got expected error: nonexistent filename provided to read()");
    $YAML::Tiny::errstr = '';
}

{
    my $file = catfile( test_data_directory(), '/' );
    eval { YAML::Tiny->read($file); };
    like(YAML::Tiny->errstr, qr/'$file' is a directory, not a file/,
        "Got expected error: directory provided to read()");
    $YAML::Tiny::errstr = '';
}

{
    my $file = test_data_file("latin1.yml");
    eval { YAML::Tiny->read($file); };
    like(YAML::Tiny->errstr, qr/\Q$file\E.*does not map to Unicode/,
        "Got expected error: UTF-8 error");
    $YAML::Tiny::errstr = '';
}

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
