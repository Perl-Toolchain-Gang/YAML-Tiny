#!/usr/bin/perl

# Plain scalars can't contain certain values. Make sure they throw
# errors in YAML::Tiny.

use strict;
BEGIN {
        $|  = 1;
        $^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests => 7;
use YAML::Tiny;





#####################################################################


my $error = 'illegal characters in plain scalar';

yaml_error(<<'...', $error);
- - 2
...

yaml_error(<<'...', $error);
foo: -
...

yaml_error(<<'...', $error);
foo: @INC
...

yaml_error(<<'...', $error);
foo: %INC
...

yaml_error(<<'...', $error);
foo: bar:
...

yaml_error(<<'...', $error);
foo: bar: baz
...

yaml_error(<<'...', $error);
foo: `perl -V`
...

