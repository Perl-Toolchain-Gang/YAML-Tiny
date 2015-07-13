# Load testing for YAML::Tiny

package Some::Class;
use overload 'bool' => sub { return ${$_[0]} };
sub new {
   my $package = shift;
   my $value = shift(@_) ? 1 : 0;
   return bless \$value, $package;
}

package YAML::Tiny::Derived;
use YAML::Tiny;
use Scalar::Util qw< blessed >;
@ISA = qw< YAML::Tiny >;

sub dumper_for_unknown {
   my ($self, $element, $prefix) = @_;
   if (defined(blessed($element)) && $element->isa('Some::Class')) {
      $prefix = defined ($prefix) ? ($prefix . ' ') : '';
      return $prefix . ($element ? 'true' : 'false');
   }
   else {
      $self->SUPER::dumper_for_unknown($element, $prefix);
   }
}

package main;

use strict;
use warnings;
use lib 't/lib';

BEGIN {
    $|  = 1;
}

use Test::More 0.88;

my $struct = {
   hey => 'you',
   tv => Some::Class->new(1),
   fv => Some::Class->new(0),
   a => [ Some::Class->new(1), Some::Class->new(0) ],
};

my $dumped = YAML::Tiny::Derived->new($struct)->write_string();

my $expected = <<'END';
---
a:
  - true
  - false
fv: false
hey: you
tv: true
END

is $dumped, $expected, 'dumper_for_unknown';

done_testing;
