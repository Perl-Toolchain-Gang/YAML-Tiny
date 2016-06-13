use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.88;
use SubtestCompat;
use TestUtils;
use TestBridge;

use YAML::Tiny ();
use Tie::IxHash;

{
    local $YAML::Tiny::PRESERVE_ORDER = 1;
    tie my %doc, "Tie::IxHash";
    tie my %sub1, "Tie::IxHash" => a1a => 1, a1b => 1, a1c => 1;
    tie my %sub2, "Tie::IxHash" => a2a => 1, a2b => 1, a2c => 1;
    tie my %sub3, "Tie::IxHash" => a3a => 1, a3b => 1, a3c => 1;

    $doc{a} = [ \%sub1, \%sub2 ];
    $doc{b} = \%sub3;

    my $yaml = YAML::Tiny->new( \%doc )->write_string;
    my $rt = YAML::Tiny->read_string( $yaml );

    is( join(" ", keys %{$rt->[0]}), "a b", "top level key order" );
    is( join(" ", keys %{$rt->[0]{a}[0]}), "a1a a1b a1c", "array elem 0 key order" );
    is( join(" ", keys %{$rt->[0]{a}[1]}), "a2a a2b a2c", "array elem 1 key order" );
    is( join(" ", keys %{$rt->[0]{b}}), "a3a a3b a3c", "sub hashref key order" );
}

done_testing;
