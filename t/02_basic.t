#!/usr/bin/perl -w

# Testing of basic document structures

use strict;
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
}

use lib catdir('t', 'lib');
use MyTests;
use Test::More tests(27);
use YAML::Tiny;





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

# Simple single quote
yaml_ok(
	"---\n- 'foo'\n",
	[ [ 'foo' ] ],
	'single_quote1',
);
yaml_ok(
	"---\n- '  '\n",
	[ [ '  ' ] ],
	'single_spaces',
);
yaml_ok(
	"---\n- ''\n",
	[ [ '' ] ],
	'single_null',
);

# Double quotes
yaml_ok(
	"--- \"  \"\n",
	[ '  ' ],
	"only_spaces",
	noyaml => 1,
);

yaml_ok(
	"--- \"  foo\"\n--- \"bar  \"\n",
	[ "  foo", "bar  " ],
	"leading_trailing_spaces",
	noyaml => 1,
);

# Implicit document start
yaml_ok(
	"foo: bar\n",
	[ { foo => 'bar' } ],
	'implicit_hash',
);
yaml_ok(
	"- foo\n",
	[ [ 'foo' ] ],
	'implicit_array',
);

# Inline nested hash
yaml_ok(
	<<'END_YAML',
---
- ~
- foo: bar
  this: that
- baz
END_YAML
	[ [ undef, { foo => 'bar', this => 'that' }, 'baz' ] ],
	'inline_nested_hash',
);

exit(0);
