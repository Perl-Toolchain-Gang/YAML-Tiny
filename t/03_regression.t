#!/usr/bin/perl

# Testing of common META.yml examples

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests(31, 0, 10);
use YAML::Tiny qw{
	Load     Dump
	LoadFile DumpFile
	freeze   thaw
};





#####################################################################
# Check Exports

ok( defined(&Load),     'Found exported Load function'     );
ok( defined(&Dump),     'Found exported Dump function'     );
ok( defined(&LoadFile), 'Found exported LoadFile function' );
ok( defined(&DumpFile), 'Found exported DumpFile function' );
ok( defined(&freeze),   'Found exported freeze function'   );
ok( defined(&thaw),     'Found exported thaw functiona'    );





#####################################################################
# In META.yml files, some hash keys contain module names

# Hash key legally containing a colon
yaml_ok(
	"---\nFoo::Bar: 1\n",
	[ { 'Foo::Bar' => 1 } ],
	'module_hash_key',
);

# Hash indented
yaml_ok(
	  "---\n"
	. "  foo: bar\n",
	[ { foo => "bar" } ],
	'hash_indented',
);





#####################################################################
# Support for literal multi-line scalars

# Declarative multi-line scalar
yaml_ok(
	  "---\n"
	. "  foo: >\n"
	. "     bar\n"
	. "     baz\n",
	[ { foo => "bar baz\n" } ],
	'simple_multiline',
	nosyck => 1,
);

# Piped multi-line scalar
yaml_ok( <<'END_YAML', [ [ "foo\nbar\n", 1 ] ], 'indented', nosyck => 1 );
---
- |
  foo
  bar
- 1
END_YAML

# ... with a pointless hyphen
yaml_ok( <<'END_YAML', [ [ "foo\nbar", 1 ] ], 'indented', nosyck => 1 );
---
- |-
  foo
  bar
- 1
END_YAML






#####################################################################
# Support for YAML version directives

# Simple inline case (comment variant)
yaml_ok(
	<<'END_YAML',
--- #YAML:1.0
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'simple_doctype_comment',
	nosyck   => 1,
);

# Simple inline case (percent variant)
yaml_ok(
	<<'END_YAML',
--- %YAML:1.0
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'simple_doctype_percent',
	noyamlpm => 1,
	noxs     => 1,
);

# Simple header (comment variant)
yaml_ok(
	<<'END_YAML',
%YAML:1.0
---
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'predocument_1_0',
	noyamlpm => 1,
	nosyck   => 1,
	noxs     => 1,
);

# Simple inline case (comment variant)
yaml_ok(
	<<'END_YAML',
%YAML 1.1
---
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'predocument_1_1',
	noyamlpm => 1,
	nosyck   => 1,
);

# Multiple inline documents (comment variant)
yaml_ok(
	<<'END_YAML',
--- #YAML:1.0
foo: bar
--- #YAML:1.0
- 1
--- #YAML:1.0
foo: bar
END_YAML
	[ { foo => 'bar' }, [ 1 ], { foo => 'bar' } ],
	'multi_doctype_comment',
	# nosyck => 1,
);

# Simple pre-document case (comment variant)
yaml_ok(
	<<'END_YAML',
%YAML 1.1
---
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'predocument_percent',
	noyamlpm => 1,
	nosyck   => 1,
);

# Simple pre-document case (comment variant)
yaml_ok(
	<<'END_YAML',
#YAML 1.1
---
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'predocument_comment',
);





#####################################################################
# Hitchhiker Scalar

yaml_ok(
	<<'END_YAML',
--- 42
END_YAML
	[ 42 ],
	'hitchhiker scalar',
	serializes => 1,
);





#####################################################################
# Null HASH/ARRAY

yaml_ok(
	<<'END_YAML',
---
- foo
- {}
- bar
END_YAML
	[ [ 'foo', {}, 'bar' ] ],
	'null hash in array',
);

yaml_ok(
	<<'END_YAML',
---
- foo
- []
- bar
END_YAML
	[ [ 'foo', [], 'bar' ] ],
	'null array in array',
);

yaml_ok(
	<<'END_YAML',
---
foo: {}
bar: 1
END_YAML
	[  { foo => {}, bar => 1 } ],
	'null hash in hash',
);

yaml_ok(
	<<'END_YAML',
---
foo: []
bar: 1
END_YAML
	[  { foo => [], bar => 1 } ],
	'null array in hash',
);




#####################################################################
# Trailing Whitespace

yaml_ok(
	<<'END_YAML',
---
abstract: Generate fractal curves 
foo: ~ 
arr:
  - foo 
  - ~
  - 'bar'  
END_YAML
	[ {
		abstract => 'Generate fractal curves',
		foo      => undef,
		arr      => [ 'foo', undef, 'bar' ],
	} ],
	'trailing whitespace',
);





#####################################################################
# Quote vs Hash

yaml_ok(
	<<'END_YAML',
---
author:
  - 'mst: Matt S. Trout <mst@shadowcatsystems.co.uk>'
END_YAML
	[ { author => [ 'mst: Matt S. Trout <mst@shadowcatsystems.co.uk>' ] } ],
	'hash-like quote',
);





#####################################################################
# Single Quote Idiosyncracy

yaml_ok(
	<<'END_YAML',
---
slash: '\\'
name: 'O''Reilly'
END_YAML
	[ { slash => "\\\\", name => "O'Reilly" } ],
	'single quote subtleties',
);





#####################################################################
# Empty Values and Premature EOF

yaml_ok(
	<<'END_YAML',
---
foo:    0
requires:
build_requires:
END_YAML
	[ { foo => 0, requires => undef, build_requires => undef } ],
	'empty hash keys',
	noyamlpm => 1,
);

yaml_ok(
	<<'END_YAML',
---
- foo
-
-
END_YAML
	[ [ 'foo', undef, undef ] ],
	'empty array keys',
	noyamlpm => 1,
);





#####################################################################
# Comment on the Document Line

yaml_ok(
	<<'END_YAML',
--- # Comment
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'comment header',
	noyamlpm => 1,
);






#####################################################################
# Newlines and tabs

yaml_ok(
	<<'END_YAML',
foo: "foo\\\n\tbar"
END_YAML
	[ { foo => "foo\\\n\tbar" } ],
	'special characters',
);





#####################################################################
# Circular Reference Protection

SCOPE: {
	my $foo = { a => 'b' };
	my $bar = [ $foo, 2 ];
	$foo->{c} = $bar;
	my $circ = YAML::Tiny->new( [ $foo, $bar ] );
	isa_ok( $circ, 'YAML::Tiny' );

	# When we try to serialize, it should NOT infinite loop
	my $string = undef;
	   $string = eval { $circ->write_string; };
	is( $string, undef, '->write_string does not return a value' );
	ok( $@, 'Error string is defined' );
	like(
		$@,
		qr/does not support circular references/,
		'Got the expected error message',
	);
}	





#####################################################################
# Confirm we can read the synopsis

yaml_ok(
	<<'END_YAML',
---
rootproperty: blah
section:
  one: two
  three: four
  Foo: Bar
  empty: ~
END_YAML
	[ {
		rootproperty => 'blah',
		section      => {
			one   => 'two',
			three => 'four',
			Foo   => 'Bar',
			empty => undef,
		},
	} ],
	'synopsis',
);





#####################################################################
# Unprintable Characters

yaml_ok(
       "--- \"foo\\n\\x00\"\n",
       [ "foo\n\0" ],
       'unprintable',
);





#####################################################################
# Empty Quote Line

yaml_ok(
	<<'END_YAML',
---
- foo
#
- bar
END_YAML
	[ [ "foo", "bar" ] ],
);





#####################################################################
# Indentation after empty hash value

yaml_ok(
	<<'END_YAML',
---
Test:
  optmods:
    Bad: 0
    Foo: 1
    Long: 0
  version: 5
Test_IncludeA:
  optmods:
Test_IncludeB:
  optmods:
_meta:
  name: 'test profile'
  note: 'note this test profile'
END_YAML
	[ {
		Test => {
			optmods => {
				Bad => 0,
				Foo => 1,
				Long => 0,
			},
			version => 5,
		},
		Test_IncludeA => {
			optmods => undef,
		},
		Test_IncludeB => {
			optmods => undef,
		},
		_meta => {
			name => 'test profile',
			note => 'note this test profile',
		},
	} ],
);





#####################################################################
# Spaces in the Key

yaml_ok(
	<<'END_YAML',
---
the key: the value
END_YAML
	[ { 'the key' => 'the value' } ],
);





#####################################################################
# Ticker #32402

# Tests a particular pathological case

yaml_ok(
	<<'END_YAML',
---
- value
- '><'
END_YAML
	[ [ 'value', '><' ] ],
	'Pathological >< case',
);





#####################################################################
# Special Characters

#yaml_ok(
#	<<'END_YAML',
#---
#- "Ingy d\xC3\xB6t Net"
#END_YAML
#	[ [ "Ingy d\xC3\xB6t Net" ] ],
#);






######################################################################
# Non-Indenting Sub-List

yaml_ok(
	<<'END_YAML',
---
foo:
- list
bar: value
END_YAML
	[ { foo => [ 'list' ], bar => 'value' } ],
	'Non-indenting sub-list',
	noyamlpm => 1,
);
