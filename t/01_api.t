# Testing of some API methods;

use strict;
use warnings;

use Test::More 0.90;
use YAML::Tiny;

# constructor and documents
{
    my @docs = ( { one => 'two' }, { three => 'four' } );
    ok( my $yaml = YAML::Tiny->new( @docs ), "constructor" );
    is_deeply( [ $yaml->documents ], \@docs, "documents (list)" );
    is( scalar $yaml->documents, 2, "documents (scalar)" );
}

done_testing;
