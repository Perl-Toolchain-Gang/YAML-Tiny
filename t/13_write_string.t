use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.88;
use SubtestCompat;
use TestUtils;
use TestBridge;

use YAML::Tiny ();

#--------------------------------------------------------------------------#
# Generally, write_string can be tested with .tml files in t/tml-local/*
#
# This file is for error tests or conditions that can't be easily tested
# via .tml
#--------------------------------------------------------------------------#

subtest 'write_string as class method' => sub {
    my $got = eval { YAML::Tiny->write_string };
    is( $@, '', "write_string lives" );
    is( $got, '', "returns empty string" );
};

subtest 'write_string preserves Tie::IxHash key order' => sub {
    eval { require Tie::IxHash };
    if ( $@ ) {
        plan skip_all => 'Tie::IxHash not available';
        return;
    }

    tie my %h, 'Tie::IxHash', ( c => 1, b => 2, a => 3 );
    my $got = YAML::Tiny->new( \%h )->write_string;
    is( $got, "---\nc: 1\nb: 2\na: 3\n", "tied hash keys appear in insertion order" );
};

done_testing;
