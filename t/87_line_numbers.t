use strict;
use warnings;
use Test::More tests => 6;
use YAML::Tiny;

# Test that parse error messages include line numbers

# Bad indenting in a hash value
{
    my $yaml = "---\nfoo: bar\n  baz: bad\n";
    eval { YAML::Tiny->read_string($yaml) };
    like $@, qr/\(line \d+\)/, "bad indenting error includes line number";
    like $@, qr/\(line 3\)/, "bad indenting error reports correct line number";
}

# Failed to classify line
{
    my $yaml = "---\n- first\nsecond\n";
    eval { YAML::Tiny->read_string($yaml) };
    like $@, qr/\(line \d+\)/, "classify error includes line number";
}

# Bad indenting with comments (comments are filtered, line numbers should still be correct)
{
    my $yaml = "---\n# comment\nfoo: bar\n# another comment\n  baz: bad\n";
    eval { YAML::Tiny->read_string($yaml) };
    like $@, qr/\(line 5\)/, "line number accounts for filtered comment lines";
}

# Unsupported feature in hash
{
    my $yaml = "---\n? complex_key\n";
    eval { YAML::Tiny->read_string($yaml) };
    like $@, qr/\(line 2\)/, "unsupported feature error includes correct line number";
}

# Valid YAML still parses fine (sanity check)
{
    my $yaml = "---\nfoo: bar\nbaz:\n  - one\n  - two\n";
    my $result = eval { YAML::Tiny->read_string($yaml) };
    ok defined $result, "valid YAML still parses correctly with line tracking";
}
