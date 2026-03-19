=pod

This test verifies that comment-like lines (starting with #) inside
literal (|) and folded (>) block scalars are preserved as content,
not stripped as YAML comments.

=cut

use Test::More tests => 2;
use YAML::Tiny;

# Comment-like line in a literal block scalar
my $yaml = <<'...';
- |
  # Perl sub:
  sub foo {}
...
is Load($yaml)->[0],
    "# Perl sub:\nsub foo {}\n",
    "Comments in literal scalars";

# Comment-like line in a folded block scalar
my $yaml2 = <<'...';
- >
  # This is not a comment
  but content
...
is Load($yaml2)->[0],
    "# This is not a comment but content\n",
    "Comments in folded scalars";
