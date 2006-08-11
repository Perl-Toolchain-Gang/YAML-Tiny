use strict;
use warnings;
use Test::More;
use YAML::Tiny;
BEGIN {
    my $res = eval { require YAML::Syck };
    if (not $res or $@) {
        Test::More->import(skip_all => "YAML::Syck not available.");
    }
    else {
        Test::More->import(tests => 3);
    }
}

my $struct = { foo => 'bar' };
my $roundtrip = YAML::Tiny->read_string( YAML::Syck::Dump($struct) );
ok(
    defined($roundtrip) && $roundtrip->isa('YAML::Tiny'),
    "Reading string succeeded"
);
ok( @{$roundtrip} == 1, "YAML::Tiny object has one document" );
is_deeply( $roundtrip->[0], $struct, "The document is the initial struct" );


