package TestMLTiny;

use strict;
use warnings;

use File::Find;

use TestUtils qw/slurp/;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    testml_all_files
    testml_parse_blocks
    testml_run_file
    testml_has_points
};

sub testml_all_files {
    my ($dir) = @_;
    my @files;
    File::Find::find(
        sub { push @files, $File::Find::name if -f and /\.tml$/ },
        $dir
    );
    return sort @files;
}

sub testml_run_file {
    my ($file, $callback) = @_;
    my $blocks = testml_parse_blocks($file);
    $callback->($_) for @$blocks;
}

sub testml_has_points {
    my ($block, @points) = @_;
    for my $point (@points) {
        defined $block->{$point} or return 0;
    }
    return 1;
}

sub testml_parse_blocks {
    my ($file) = @_;

    my $testml = slurp($file, ":encoding(UTF-8)");
    my $lines = [ grep { ! /^#/ } split /\n/, $testml ];

    shift @$lines while @$lines and $lines->[0] =~ /^ *$/;
    $lines->[0] =~ /^===\s+\S.*$/
        or die "$file does not start with a valid block";

    my $blocks = [];
    my $parse = [];
    push @$lines, undef; # sentinel
    while (@$lines) {
        push @$parse, shift @$lines;
        if ( !defined($lines->[0]) or $lines->[0] =~ /^===\s+\S.*$/ ) {
            my $block = parse_testml_block($file, $parse);
            push @$blocks, $block
                unless exists $block->{SKIP};
            last if exists $block->{LAST};
            $parse = []; # clear for next parse
        }
        last if !defined($lines->[0]);
    }

    # Take first ONLY block if one exists
    my $only = [ grep { exists $_->{ONLY} } @$blocks ];

    return @$only ? $only : $blocks;
}

sub parse_testml_block {
    my ($file, $lines) = @_;

    # extract test block name
    my ($label) = $lines->[0] =~ /^===\s+(.*)$/;
    die "Invalid TestML block label in $file: $lines->[0]\n"
        unless defined $label && length $label;
    shift @$lines until $lines->[0] =~ /^--- +\w+/;

    # extract test block points
    my $block = parse_testml_points($file, $label, $lines);
    $block->{Label} = $label;

    return $block;
}

sub parse_testml_points {
    my ($file, $label, $lines) = @_;

    my $block = {};

    $lines->[0] =~ /^--- +(\w+)$/
        or die "$file block $label does not start with a valid point";

    my $point_name = '';
    for my $line ( @$lines ) {
        if ( $line =~ /^--- (\w+)$/ ) {
            $point_name = $1;
            die "$file block $label repeats $point_name"
                if exists $block->{$point_name};
            $block->{$point_name} = '';
        }
        else {
            $block->{$point_name} .= "$line\n";
        }
    }
    for $point_name ( keys %$block ) {
        $block->{$point_name} =~ s/\n\s*\z/\n/;
        $block->{$point_name} =~ s/^\\//gm;
    }
    return $block;
}

1;
