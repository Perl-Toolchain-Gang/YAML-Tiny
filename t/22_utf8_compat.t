use utf8;
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.88;
use SubtestCompat;
use TestBridge;

#--------------------------------------------------------------------------#
# Tests for DumpUTF8 / LoadUTF8 -- the UTF-8 octet API (issue #11)
#
# Dump/Load work with character strings (no encoding).
# DumpUTF8/LoadUTF8 work with UTF-8 encoded byte strings.
#--------------------------------------------------------------------------#

subtest 'DumpUTF8 and LoadUTF8 are importable' => sub {
    package main::utf8_imports;
    use YAML::Tiny qw/DumpUTF8 LoadUTF8/;
    ::ok( defined(&DumpUTF8), 'DumpUTF8 is importable' );
    ::ok( defined(&LoadUTF8), 'LoadUTF8 is importable' );
};

use YAML::Tiny qw/Dump Load DumpUTF8 LoadUTF8/;

subtest 'DumpUTF8 returns UTF-8 octets for ASCII' => sub {
    my $data   = { name => 'foo' };
    my $chars  = Dump($data);
    my $octets = DumpUTF8($data);

    # For pure ASCII content the bytes and chars should be equal
    ok( !utf8::is_utf8($octets), 'DumpUTF8 output has no utf8 flag (is octets)' );
    is( $octets, $chars, 'DumpUTF8 ASCII output equals Dump output' );
};

subtest 'DumpUTF8 returns UTF-8 octets for Unicode data' => sub {
    my $data   = { name => "Ångström" };    # contains non-ASCII chars
    my $chars  = Dump($data);
    my $octets = DumpUTF8($data);

    ok( utf8::is_utf8($chars),   'Dump output has utf8 flag (is characters)' );
    ok( !utf8::is_utf8($octets), 'DumpUTF8 output has no utf8 flag (is octets)' );

    # octets should be longer (multi-byte encoding)
    ok( length($octets) > length($chars), 'UTF-8 bytes longer than character string for non-ASCII' )
        or diag "chars=".length($chars)." octets=".length($octets);
};

subtest 'LoadUTF8 parses UTF-8 octets' => sub {
    my $data    = { name => "日本語" };
    my $octets  = DumpUTF8($data);

    ok( !utf8::is_utf8($octets), 'DumpUTF8 output is octets' );

    my $loaded = LoadUTF8($octets);
    cmp_deeply( $loaded, $data, 'LoadUTF8 round-trip preserves data' );
};

subtest 'DumpUTF8/LoadUTF8 round-trip (list context)' => sub {
    my @docs   = ( { one => "Ångström" }, [ "日本語", "café" ] );
    my $octets = DumpUTF8(@docs);

    my @loaded = LoadUTF8($octets);
    cmp_deeply( \@loaded, \@docs, 'DumpUTF8/LoadUTF8 round-trip in list context' );
};

subtest 'LoadUTF8 errors on invalid UTF-8' => sub {
    my $bad_bytes = "\x80\x81\x82";    # invalid UTF-8 sequence
    eval { LoadUTF8($bad_bytes) };
    error_like(
        qr/valid UTF-8/i,
        'LoadUTF8 dies on invalid UTF-8 bytes'
    );
};

subtest 'Dump output is NOT encoded (characters, not octets)' => sub {
    my $data = { name => "café" };
    my $out  = Dump($data);
    ok( utf8::is_utf8($out), 'Dump output has utf8 flag (is characters, not octets)' );
};

done_testing;
