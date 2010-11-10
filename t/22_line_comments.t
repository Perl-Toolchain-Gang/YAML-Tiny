#!/usr/bin/perl

# Testing of inline comments. These comments can be quite useful in config
# files and people will expect them to work.

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

# use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests(1);
use YAML::Tiny;





#####################################################################


# Line comments in various places
# yaml_ok(
#     <<'END_YAML',
is_deeply(
    YAML::Tiny::Load(<<'END_YAML'),
a: b#content
c: d #comment
e:
- f #comment
- g# content
h: 'single'     # comment
i: "double"     # comment
j: |        # comment
    literal # content
    block   # content
k: {}       # comment
l: []       # comment
m:      # comment
  n: o
END_YAML
    [
        {
            a => 'b#content',
            c => 'd',
            e => [
                'f',
                'g# content',
            ],
            h => 'single',
            i => 'double',
            j => "literal # content\nblock   # content\n",
            k => {},
            l => [],
            m => {
                n => 'o',
            }
        },
    ],
    'Properly ignore comments',
);
