#!/usr/bin/perl -w

# Main testing for YAML::Tiny

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import(
			catdir( 'blib', 'lib' ),
			catdir( 'blib', 'arch' ),
			'lib'
			);
	}
}

use Test::More tests => (16 * 7);
use YAML::Tiny;

# Do we have the authorative YAML to test against
eval { require YAML; };
my $COMPARE = !! $YAML::VERSION;

# 7 tests per call
sub parses_to {
	my $name     = shift;
	my $string   = shift;
	my $expected = shift;
	bless $expected, 'YAML::Tiny';

	SKIP: {
		# Parse in the string
		my $yaml = eval { YAML::Tiny->read_string( $string ); };
		isa_ok( $yaml, 'YAML::Tiny' );
		skip( "$name: Message failed to read", 7 ) unless $yaml;
		is_deeply( $yaml, $expected, "$name: Parsed object matches expected" );

		# Round-trip the object
		my $output = $yaml->write_string;
		ok( (defined $output and ! ref $output),
			"$name: ->write_string writes a string" );
		my $yaml2 = YAML::Tiny->read_string( $output );
		isa_ok( $yaml2, 'YAML::Tiny' );
		is_deeply( $yaml, $yaml2, "$name: Perl->String->Perl round trip ok" );

		# If YAML itself is available, compare
		skip( "No YAML.pm to compare with", 2 ) unless $COMPARE;
		my @docs = eval { YAML::Load( $string ) };
		is( $@, '', "$name: YAML.pm loads the string ok" );
		is_deeply( \@docs, $expected, "$name: YAML.pm matches YAML::Tiny" );		
	}
}





#####################################################################
# Sample Testing

# Test a completely empty document
parses_to( empty => '', [  ] );

# Just a newline
### YAML.pm has a bug where it dies on a single newline
parses_to( only_newlines => "\n\n", [ ] );

# Just a comment
parses_to( only_comment  => "# comment\n", [ ] );

# Empty document
parses_to( only_header   => "---\n",        [ undef ]        );
parses_to( two_header    => "---\n---\n",   [ undef, undef ] );
parses_to( one_undef     => "--- ~\n",      [ undef ]        );
parses_to( one_undef2    => "---  ~\n",     [ undef ]        );
parses_to( two_undef     => "--- ~\n---\n", [ undef, undef ] );

# Just a scalar
parses_to( one_scalar    => "--- foo\n",  [ 'foo' ] );
parses_to( one_scalar2   => "---  foo\n", [ 'foo' ] );
parses_to( two_scalar    => "--- foo\n--- bar\n", [ 'foo', 'bar' ] );

# Simple lists
parses_to( one_list1     => "---\n- foo\n", [ [ 'foo' ] ] );
parses_to( one_list2     => "---\n- foo\n- bar\n", [ [ 'foo', 'bar' ] ] );
parses_to( one_listundef => "---\n- ~\n- bar\n", [ [ undef, 'bar' ] ] );

# Simple hashs
parses_to( 'one_hash1',
	"---\nfoo: bar\n",
	[ { foo => 'bar' } ],
);

parses_to( 'one_hash2',
	"---\nfoo: bar\nthis: ~\n",
	[ { this => undef, foo => 'bar' } ],
);




#####################################################################
# Error Testing

exit(0);
