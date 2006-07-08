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

use Test::More tests => (22 * 15);
use YAML::Tiny;

# Do we have the authorative YAML to test against
eval { require YAML; };
my $COMPARE = !! $YAML::VERSION;

# 7 tests per call
sub yaml_ok {
	my $string = shift;
	my $object = shift;
	my $name   = shift || 'unnamed';
	bless $object, 'YAML::Tiny';

	# If YAML itself is available, test with it first
	SKIP: {
		skip( "Skipping compatibility testing (no YAML.pm)", 4 ) unless $COMPARE;

		# Test writing with YAML.pm
		my $yamlpm_out = eval { YAML::Dump( @$object ) };
		is( $@, '', "$name: YAML.pm saves without error" );
		SKIP: {
			skip( "Shortcutting after failure", 1 ) if $@;
			ok(
				!!(defined $yamlpm_out and ! ref $yamlpm_out),
				"$name: YAML.pm serializes correctly",
			);
			my @yamlpm_round = eval { YAML::Load( $yamlpm_out ) };
			is( $@, '', "$name: YAML.pm round-trips without error" );
			skip( "Shortcutting after failure", 2 ) if $@;
			my $round = bless [ @yamlpm_round ], 'YAML::Tiny';
			isa_ok( $round, 'YAML::Tiny' );
			is_deeply( $round, $object, "$name: YAML.pm round-trips correctly" );		
		}

		# Test reading with YAML.pm
		my @yamlpm_in = eval { YAML::Load( $string ) };
		is( $@, '', "$name: YAML.pm loads without error" );
		SKIP: {
			skip( "Shortcutting after failure", 1 ) if $@;
			is_deeply( \@yamlpm_in, $object, "$name: YAML.pm parses correctly" );
		}
	}

	# Does the string parse to the structure
	my $yaml = eval { YAML::Tiny->read_string( $string ); };
	is( $@, '', "$name: YAML::Tiny parses without error" );
	SKIP: {
		skip( "Shortcutting after failure", 2 ) if $@;
		isa_ok( $yaml, 'YAML::Tiny' );
		is_deeply( $yaml, $object, "$name: YAML::Tiny parses correctly" );
	}

	# Does the structure serialize to the string.
	# We can't test this by direct comparison, because any
	# whitespace or comments would be lost.
	# So instead we parse back in.
	my $output = eval { $object->write_string };
	is( $@, '', "$name: YAML::Tiny serializes without error" );
	SKIP: {
		skip( "Shortcutting after failure", 4 ) if $@;
		ok(
			!!(defined $output and ! ref $output),
			"$name: YAML::Tiny serializes correctly",
		);
		my $roundtrip = eval { YAML::Tiny->read_string( $output ) };
		is( $@, '', "$name: YAML::Tiny round-trips without error" );
		skip( "Shortcutting after failure", 2 ) if $@;
		isa_ok( $roundtrip, 'YAML::Tiny' );
		is_deeply( $roundtrip, $object, "$name: YAML::Tiny round-trips correctly" );
	}

	# Return true as a convenience
	return 1;
}





#####################################################################
# Sample Testing

# Test a completely empty document
yaml_ok(
	'',
	[  ],
	'empty',
);

# Just a newline
### YAML.pm has a bug where it dies on a single newline
yaml_ok(
	"\n\n",
	[ ],
	'only_newlines',
);

# Just a comment
yaml_ok(
	"# comment\n",
	[ ],
	'only_comment',
);

# Empty documents
yaml_ok(
	"---\n",
	[ undef ],
	'only_header',
);
yaml_ok(
	"---\n---\n",
	[ undef, undef ],
	'two_header',
);
yaml_ok(
	"--- ~\n",
	[ undef ],
	'one_undef',
);
yaml_ok(
	"---  ~\n",
	[ undef ],
	'one_undef2',
);
yaml_ok(
	"--- ~\n---\n",
	[ undef, undef ],
	'two_undef',
);

# Just a scalar
yaml_ok(
	"--- foo\n",
	[ 'foo' ],
	'one_scalar',
);
yaml_ok(
	"---  foo\n",
	[ 'foo' ],
	'one_scalar2',
);
yaml_ok(
	"--- foo\n--- bar\n",
	[ 'foo', 'bar' ],
	'two_scalar',
);

# Simple lists
yaml_ok(
	"---\n- foo\n",
	[ [ 'foo' ] ],
	'one_list1',
);
yaml_ok(
	"---\n- foo\n- bar\n",
	[ [ 'foo', 'bar' ] ],
	'one_list2',
);
yaml_ok(
	"---\n- ~\n- bar\n",
	[ [ undef, 'bar' ] ],
	'one_listundef',
);

# Simple hashs
yaml_ok(
	"---\nfoo: bar\n",
	[ { foo => 'bar' } ],
	'one_hash1',
);

yaml_ok(
	"---\nfoo: bar\nthis: ~\n",
	[ { this => undef, foo => 'bar' } ],
 	'one_hash2',
);





#####################################################################
# Two-level recursion

# Simple array inside a hash with an undef
yaml_ok(
	<<'END_YAML',
---
foo:
  - bar
  - ~
  - baz
END_YAML
	[ { foo => [ 'bar', undef, 'baz' ] } ],
	'array_in_hash',
);



# Simple hash inside a hash with an undef
yaml_ok(
	<<'END_YAML',
---
foo: ~
bar:
  foo: bar
END_YAML
	[ { foo => undef, bar => { foo => 'bar' } } ],
	'hash_in_hash',
);



# Mixed hash and scalars inside an array
yaml_ok(
	<<'END_YAML',
---
-
  foo: ~
  this: that
- foo
- ~
-
  foo: bar
  this: that
END_YAML
	[ [
		{ foo => undef, this => 'that' },
		'foo',
		undef,
		{ foo => 'bar', this => 'that' },
	] ],
	'hash_in_array',
);





#####################################################################
# Future Things

# Double quotes
SKIP: {
	skip( "Skipping double-quotes", 45 );

	yaml_ok(
		"--- \"  \"\n",
		[ '  ' ],
		"only_spaces",
	);

	yaml_ok(
		"--- \"  foo\"\n--- \"bar  \"\n",
		[ "  foo", "bar  " ],
		"leading_trailing_spaces",
	);

	yaml_ok(
		"--- \"\n\"\n",
		[ "\n" ],
		"only_spaces",
	);

}





#####################################################################
# Error Testing

exit(0);
