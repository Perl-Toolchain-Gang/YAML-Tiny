# TestMLTiny is a small, one file module that offers the data format of TestML
# and a test file runner method.
package TestMLTiny;

use strict;
use warnings;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    testml_run_file
    testml_has_points
    testml_parse_blocks
};

sub testml_run_file {
    my ($file, $code) = @_;

    my $blocks = testml_parse_blocks($file);

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

sub testml_parse_blocks {
    my ($file) = @_;

    my $testml = do {
        open my $fh, "<:raw:encoding(UTF-8)", $file; local $/; <$fh>
    };
    my $lines = [ grep { ! /^#/ } split /\n/, $testml ];

    # Skip over possible TestML code:
    shift @$lines while @$lines and $lines->[0] !~ /^===/;

    my $blocks = [];
    my $parse = [];
    push @$lines, undef; # sentinel
    while (@$lines) {
        push @$parse, shift @$lines;
        if ( !defined($lines->[0]) or $lines->[0] =~ /^===/ ) {
            my $block = _parse_testml_block($file, $parse);
            push @$blocks, $block
                unless exists $block->{SKIP};
            last if exists $block->{LAST};
            $parse = []; # clear for next parse
        }
        last if !defined($lines->[0]);
    }

    my $only = [ grep { exists $_->{ONLY} } @$blocks ];

    return @$only ? $only : $blocks;
}

sub _parse_testml_block {
    my ($file, $lines) = @_;

    # extract test block label
    my ($label) = $lines->[0] =~ /^===(?:\s+(.*))?$/;
    die "Invalid TestML block label in $file: $lines->[0]\n"
        unless defined $label && length $label;
    shift @$lines until $lines->[0] =~ /^--- +\w+/;

    # extract test block points
    my $block = _parse_testml_points($file, $label, $lines);
    $block->{Label} = $label;

    return $block;
}

sub _parse_testml_points {
    my ($file, $label, $lines) = @_;

    my $block = {};

    while (@$lines) {
        my $line = shift @$lines;
        $line =~ /^--- +(\w+)/
            or die "Invalid TestML line in '$file':\n'$line'";
        my $point_name = $1;
        die "$file block $label repeats $point_name"
            if exists $block->{$point_name};
        $block->{$point_name} = '';
        if ($line =~ /^--- +(\w+): +(.*?) *$/) {
            $block->{$1} .= "$2\n";
        }
        elsif ($line =~ /^--- +(\w+)$/) {
            $point_name = $1;
            while ( @$lines ) {
                $line = shift @$lines;
                if ($line =~ /^--- \w+/) {
                    unshift @$lines, $line;
                    last;
                }
                $block->{$point_name} .= "$line\n";
            }
            $block->{$point_name} =~ s/\n\s*\z/\n/;
            $block->{$point_name} =~ s/^\\//gm;
        }
        else {
            die "Invalid TestML line in '$file':\n'$line'";
        }
    }
    return $block;
}

1;
