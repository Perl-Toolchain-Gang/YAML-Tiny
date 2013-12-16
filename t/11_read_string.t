use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;
use TestBridge;

use YAML::Tiny ();

#--------------------------------------------------------------------------#
# Generally, read_string can be tested with .tml files in t/tml-local/*
#
# This file is for error tests that can't be easily tested via .tml
#--------------------------------------------------------------------------#

subtest 'read_string without arg' => sub {
    eval { YAML::Tiny->read_string(); };
    error_like(qr/Did not provide a string to load/,
        "Got expected error: no string provided to read_string()"
    );
};

subtest 'YAML without newline' => sub {
    my $str = join("\n" => ('---', '- foo', '---', '- bar', '---'));
    my $obj = eval { YAML::Tiny->read_string($str); };
    is( $@, '', "YAML without newline is OK");
};

subtest 'read_string as object method' => sub {
    ok( my $obj = YAML::Tiny->new( { foo => 'bar' } ), "new YAML object" );
    ok( my $obj2 = $obj->read_string( "---\nfoo: bar\n"  ),
        "read_string object method"
    );
    isnt( $obj, $obj2, "objects are different" );
    cmp_deeply( $obj, $obj2, "objects have same content" );
};

subtest 'invalid UTF-8' => sub {
    # get invalid UTF-8 by reading Latin-1 with lax :utf8 layer
    my $string = do {
        local $SIG{__WARN__} = sub {};
        slurp( test_data_file('latin1.yml'), ":utf8" );
    };
    my $obj = eval { YAML::Tiny->read_string($string); };
    is( $obj, undef, "read_string should return undef" );
    error_like( qr/invalid UTF-8 string/,
        "Got expected error about invalid UTF-8 string"
    );
};

done_testing;
