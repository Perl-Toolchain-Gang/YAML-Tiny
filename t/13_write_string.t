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

subtest '$SORT_KEYS controls key ordering in output' => sub {
    my $hash = { z => 1, a => 2, m => 3 };
    my $yt = YAML::Tiny->new($hash);

    # Default: keys are sorted
    {
        my $out = $yt->write_string;
        like( $out, qr/a:.*m:.*z:/s, "keys sorted by default" );
    }

    # With SORT_KEYS disabled: keys appear in hash-native order (unsorted)
    {
        local $YAML::Tiny::SORT_KEYS = 0;
        my $out = $yt->write_string;
        # We can't predict hash order, but we CAN verify round-trip works
        my $rt = YAML::Tiny->read_string($out);
        is_deeply( $rt->[0], $hash, "round-trip works with SORT_KEYS=0" );
    }

    # Verify default is restored
    {
        my $out = $yt->write_string;
        like( $out, qr/a:.*m:.*z:/s, "keys sorted again after local scope" );
    }
};

done_testing;
