#!/usr/bin/perl

# Testing of common META.yml examples

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests(17);
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
	[ { abstract => 'Generate fractal curves', foo => undef, arr => [ 'foo', undef, 'bar' ] } ],
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
slash: '\'
name: 'O''Reilly'
END_YAML
	[ { slash => "\\", name => "O'Reilly" } ],
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
	noyaml => 1,
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
	noyaml => 1,
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
	noyaml => 1,
);

exit(0);
