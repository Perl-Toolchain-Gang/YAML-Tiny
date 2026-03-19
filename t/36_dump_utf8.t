use strict;
use warnings;
use utf8;
use Test::More 0.88;
use YAML::Tiny;

# Issue #36: _dump_scalar was mangling UTF-8 encoded byte strings.
# When a string had its UTF8 flag cleared (via utf8::encode), bytes in the
# range 0x80-0x9F (UTF-8 continuation bytes) were incorrectly treated as
# C1 control characters and escaped, breaking the UTF-8 sequences.

my $chars = "美国的私有退休金体制\n";

# Wide character string (Perl's internal representation)
my $yaml_chars = YAML::Tiny::Dump( { key => $chars } );

# UTF-8 encoded byte string (same text, but bytes with no UTF8 flag)
my $octets = $chars;
utf8::encode($octets);
my $yaml_octets = YAML::Tiny::Dump( { key => $octets } );

# Extract the dumped values
my ($dumped_chars)  = $yaml_chars  =~ /key: (.*)/;
my ($dumped_octets) = $yaml_octets =~ /key: (.*)/;

# Both should produce the same YAML representation.
# Before the fix, the encoded byte string had its UTF-8 continuation bytes
# (0x80-0x9F) individually escaped, producing different output.
is( $dumped_octets, $dumped_chars,
    'UTF-8 encoded byte string dumps same as wide char string' );

# Verify the wide char string round-trips correctly through dump/load
my $loaded = YAML::Tiny::Load($yaml_chars);
is( $loaded->{key}, $chars, 'wide char string round-trips through dump/load' );

# Verify that a string with actual C1 control characters still gets escaped
my $c1_string = "before\x{85}after";  # U+0085 is a C1 control (NEL)
my $yaml_c1 = YAML::Tiny::Dump( [ $c1_string ] );
like( $yaml_c1, qr/\\N/, 'C1 control character (NEL) is still escaped' );

done_testing;
