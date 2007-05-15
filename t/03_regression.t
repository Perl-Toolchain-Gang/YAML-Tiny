#!/usr/bin/perl -w

# Testing of common META.yml examples

use strict;
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
}

use lib catdir('t', 'lib');
use MyTests;
use Test::More tests(5);
use YAML::Tiny;





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





#####################################################################
# Support for YAML document version declarations

# Simple case
yaml_ok(
	<<'END_YAML',
--- #YAML:1.0
foo: bar
END_YAML
	[ { foo => 'bar' } ],
	'simple_doctype',
	nosyck => 1,
);

# Multiple documents
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
	'multi_doctype',
	nosyck => 1,
);

exit(0);
