# TestMLTiny is a small, one file module that offers the data format of TestML
# and a test file runner method.
package TestMLTiny;

use strict;
use warnings;

use TestML::Tiny;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    testml_run_file
    testml_has_points
};

sub testml_run_file {
    my ($file, $code) = @_;

    my $blocks = TestML::Tiny->new(
        testml => $file,
        version => '0.1.0',
    )->{function}{data};

    $code->($file, $blocks);
}

sub testml_has_points {
    my ($block, @points) = @_;
    my @values;
    for my $point (@points) {
        defined $block->{$point} or return;
        push @values, $block->{$point};
    }
    push @values, $block->{Label};
    return @values;
}

1;
