# Testing documents that should fail
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;

use File::Spec::Functions ':ALL';



#####################################################################
# Customized Class

SCOPE: {
    package Foo;
    use XXX;

    use YAML::Tiny;

    use vars qw{@ISA};
    BEGIN {
        @ISA = 'YAML::Tiny';
    }

    # XXX-INGY subclasses should not use private methods… or if they
    # do they should expect method name changes.
    # sub _write_scalar {

    sub _dump_scalar {
        my $self   = shift;
        my $string = shift;
        my $indent = shift;
        if ( defined $indent ) {
            return "'$indent'";
        } else {
            return $string;
        }
    }

    1;
}





#####################################################################
# Generate the value

my $object = Foo->new(
    { foo => 'bar' }
);
is( $object->write_string, "---\nfoo: '1'\n", 'Subclassing works' );

done_testing;
