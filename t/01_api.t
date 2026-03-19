# Testing of some API methods;

use strict;
use warnings;

use lib 't/lib/';
use Test::More 0.88;
use SubtestCompat;
use TestBridge;
use YAML::Tiny;

subtest "default exports" => sub {
    ok( defined(&Load),         'Found exported Load function'   );
    ok( defined(&Dump),         'Found exported Dump function'   );
    ok( \&main::Load == \&YAML::Tiny::Load, 'Load is YAML::Tiny' );
    ok( \&main::Dump == \&YAML::Tiny::Dump, 'Dump is YAML::Tiny' );
    ok( !defined(&LoadFile), 'LoadFile function not exported' );
    ok( !defined(&DumpFile), 'DumpFile function not exported' );
    ok( !defined(&freeze),   'freeze function not exported'   );
    ok( !defined(&thaw),     'thaw functiona not exported'    );
};

subtest "all exports" => sub {
    package main::all_exports;
    use Test::More 0.88;
    use YAML::Tiny qw/Load Dump LoadFile DumpFile freeze thaw/;
    ok( defined(&Load),         'Found exported Load function'     );
    ok( defined(&Dump),         'Found exported Dump function'     );
    ok( defined(&LoadFile), 'Found exported LoadFile function' );
    ok( defined(&DumpFile), 'Found exported DumpFile function' );
    ok( defined(&freeze),   'Found exported freeze function'   );
    ok( defined(&thaw),     'Found exported thaw functiona'    );
};

subtest "constructor and documents" => sub {
    my @docs = ( { one => 'two' }, { three => 'four' } );
    ok( my $yaml = YAML::Tiny->new( @docs ), "constructor" );
    cmp_deeply( [ @$yaml ], \@docs, "the object is an arrayref of documents" );
};

subtest "documents() accessor" => sub {
    my @docs = ( { one => 'two' }, { three => 'four' } );
    my $yaml = YAML::Tiny->new( @docs );

    my @got = $yaml->documents;
    cmp_deeply( \@got, \@docs, "documents() returns all documents" );

    # Empty object
    my $empty = YAML::Tiny->new;
    my @none = $empty->documents;
    cmp_deeply( \@none, [], "documents() returns empty list for empty object" );
};

subtest "document() accessor" => sub {
    my @docs = ( { one => 'two' }, { three => 'four' }, [ 'a', 'b' ] );
    my $yaml = YAML::Tiny->new( @docs );

    cmp_deeply( $yaml->document(0), $docs[0], "document(0) returns first doc" );
    cmp_deeply( $yaml->document(1), $docs[1], "document(1) returns second doc" );
    cmp_deeply( $yaml->document(2), $docs[2], "document(2) returns third doc" );

    # Negative index
    cmp_deeply( $yaml->document(-1), $docs[2], "document(-1) returns last doc" );

    # Out of bounds returns undef
    is( $yaml->document(99), undef, "document(99) returns undef for out-of-bounds" );
};

done_testing;
