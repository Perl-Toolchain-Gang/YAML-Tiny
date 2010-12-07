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
use Test::More tests => 11;
use YAML::Tiny;





#####################################################################
# Main Tests

my $error1 = 'does not support a feature';
my $error2 = 'illegal characters in plain scalar';

yaml_error( <<'END_YAML', $error1 );
- 'Multiline
quote'
END_YAML

yaml_error( <<'END_YAML', $error1 );
- "Multiline
quote"
END_YAML

yaml_error( <<'END_YAML', $error1 );
- !something
END_YAML

yaml_error( <<'END_YAML', $error1 );
- &node
END_YAML

yaml_error( <<'END_YAML', $error2 );
- - 2
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: -
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: @INC
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: %INC
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: bar:
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: bar: baz
END_YAML

yaml_error( <<'END_YAML', $error2 );
foo: `perl -V`
END_YAML
