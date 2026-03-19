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
    ok( !defined(&LoadFile),  'LoadFile function not exported'  );
    ok( !defined(&DumpFile),  'DumpFile function not exported'  );
    ok( !defined(&LoadUTF8),  'LoadUTF8 function not exported'  );
    ok( !defined(&DumpUTF8),  'DumpUTF8 function not exported'  );
    ok( !defined(&freeze),    'freeze function not exported'    );
    ok( !defined(&thaw),      'thaw functiona not exported'     );
};

subtest "all exports" => sub {
    package main::all_exports;
    use Test::More 0.88;
    use YAML::Tiny qw/Load Dump LoadFile DumpFile LoadUTF8 DumpUTF8 freeze thaw/;
    ok( defined(&Load),         'Found exported Load function'     );
    ok( defined(&Dump),         'Found exported Dump function'     );
    ok( defined(&LoadFile),  'Found exported LoadFile function'  );
    ok( defined(&DumpFile),  'Found exported DumpFile function'  );
    ok( defined(&LoadUTF8),  'Found exported LoadUTF8 function'  );
    ok( defined(&DumpUTF8),  'Found exported DumpUTF8 function'  );
    ok( defined(&freeze),    'Found exported freeze function'    );
    ok( defined(&thaw),      'Found exported thaw functiona'     );
};

subtest "constructor and documents" => sub {
    my @docs = ( { one => 'two' }, { three => 'four' } );
    ok( my $yaml = YAML::Tiny->new( @docs ), "constructor" );
    cmp_deeply( [ @$yaml ], \@docs, "the object is an arrayref of documents" );
};

done_testing;
