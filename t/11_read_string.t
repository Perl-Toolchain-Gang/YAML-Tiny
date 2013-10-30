use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestBridge;

use YAML::Tiny ();

#--------------------------------------------------------------------------#
# Generally, read_string can be tested with .tml files in t/tml-local/*
#
# This file is for error tests that can't be easily tested via .tml
#--------------------------------------------------------------------------#

{
    eval { YAML::Tiny->read_string(); };
    error_like(qr/Did not provide a string to load/,
        "Got expected error: no string provided to read_string()"
    );
}

{
    my $str = join("\n" => ('---', '- foo', '---', '- bar', '---'));
    eval { YAML::Tiny->read_string($str); };
    is( YAML::Tiny->errstr, '', "YAML without newline is OK");
}

done_testing;
