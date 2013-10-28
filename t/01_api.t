# Testing of some API methods;

use strict;
use warnings;

use Test::More 0.99;
use YAML::Tiny;

subtest "default exports" => sub {
    package main::with_default;
    use Test::More;
    use YAML::Tiny;
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
    use Test::More;
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
    is_deeply( [ $yaml->documents ], \@docs, "documents (list)" );
    is( scalar $yaml->documents, 2, "documents (scalar)" );
};

done_testing;
