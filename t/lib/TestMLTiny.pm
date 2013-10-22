package TestMLTiny;

use strict;
use warnings;

use File::Find;

use Exporter   ();
use vars qw{@ISA @EXPORT};
BEGIN {
    @ISA    = qw{ Exporter };
    @EXPORT = qw{
        testml_require_json_or_skip_all
        testml_all_files
        testml_parse_blocks
        testml_run_file
        testml_has_points
    };
}

{
    package main;
    use Test::More 0.96;

    # Set up output handles for characters
    if ( $] > '5.008' ) {
        binmode(Test::More->builder->$_, ":utf8")
            for qw/output failure_output todo_output/;
    }
}

# Prefer JSON to JSON::PP; skip if we don't have at least one
sub testml_require_json_or_skip_all {
    for (qw/JSON JSON::PP/) {
        return $_ if eval "require $_; 1";
    }
    main::plan skip_all => "no JSON or JSON::PP";
}

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
    my @lines = map { s/^\\//; $_ } grep { !/^#/ } split /\n/, $testml;

    $lines[0] =~ /^===\s+\S.*$/
        or die "$file does not start with a valid block";

    my $blocks = [];
    my $parse = [];
    push @lines, undef; # sentinel
    while (@lines) {
        push @$parse, shift @lines;
        if ( !defined($lines[0]) || $lines[0] =~ /^===\s+\S.*$/ ) {
            my $block = parse_test_block($file, $parse);
            push @$blocks, $block
                unless exists $block->{SKIP};
            last if exists $block->{LAST};
            $parse = []; # clear for next parse
        }
        last if !defined($lines[0]);
    }

    # Take first ONLY block if one exists
    my $only = [ grep { exists $_->{ONLY} } @$blocks ];

    return @$only ? $only : $blocks;
}

sub parse_test_block {
    my ($file, $lines) = @_;

    # extract test block name
    my ($label) = $lines->[0] =~ /^===\s+(.*)$/;
    die "Invalid TML block name in $file: $lines->[0]\n"
        unless defined $label && length $label;
    shift @$lines until $lines->[0] =~ /^---/;

    # extract test block points
    my $block = parse_testml_points($file, $label, $lines);
    $block->{Label} = $label;

    return $block;
}

sub parse_testml_points {
    my ($file, $label, $lines) = @_;

    $lines->[0] =~ /^--- (\w+)$/
        or die "$file block $label does not start with a valid point";

    my ($point_name, %points) = '';
    for my $line ( @$lines ) {
        if ( $line =~ /^--- (\w+)$/ ) {
            $point_name = $1;
            die "$file block $label repeats $point_name"
                if exists $points{$point_name};
            $points{$point_name} = '';
        }
        else {
            $points{$point_name} .= "$line\n";
        }
    }

    return \%points;
}

sub slurp {
    my $file = shift;
    local $/ = undef;
    open( FILE, " $file" ) or die "open($file) failed: $!";
    binmode( FILE, $_[0] ) if @_ > 0 && $] > 5.006;
    # binmode(FILE); # disable perl's BOM interpretation
    my $source = <FILE>;
    close( FILE ) or die "close($file) failed: $!";
    $source;
}

1;
