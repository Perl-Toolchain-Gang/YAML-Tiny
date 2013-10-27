package TestUtils;

use strict;
use warnings;

use Exporter   ();
use File::Spec ();
use File::Find ();

use Test::More 0.99;
use TestMLTiny;

BEGIN {
    $|  = 1;
    binmode(Test::More->builder->$_, ":utf8")
        for qw/output failure_output todo_output/;
}

our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    run_all_testml_files
    tests  yaml_ok  yaml_error slurp  load_ok
    test_data_directory test_data_file
    json_class
    plan
};

# Prefer JSON to JSON::PP; skip if we don't have at least one
sub json_class {
    for (qw/JSON JSON::PP/) {
        return $_ if eval "require $_; 1";
    }
    return;
}

sub test_data_directory {
    return File::Spec->catdir( 't', 'data' );
}

sub test_data_file {
    return File::Spec->catfile( test_data_directory(), shift );
}

sub run_all_testml_files {
    my ($label, $dir, $bridge, @args) = @_;

    my $code = sub {
        my ($file, $blocks) = @_;
        subtest "$label: $file" => sub {
            plan tests => scalar @$blocks;
            $bridge->($_, @args) for @$blocks;
        };
    };

    my @files;
    File::Find::find(
        sub { push @files, $File::Find::name if -f and /\.tml$/ },
        $dir
    );

    testml_run_file($_, $code) for sort @files;

    done_testing;
}

sub yaml_ok {
    my $string  = shift;
    my $object  = shift;
    my $name    = shift || 'unnamed';
    my %options = ( @_ );
    bless $object, 'YAML::Tiny';

    # Does the string parse to the structure
    my $yaml_copy = $string;
    my $yaml      = eval { YAML::Tiny->read_string( $yaml_copy ); };
    is( $@, '', "$name: YAML::Tiny parses without error" );
    is( $yaml_copy, $string, "$name: YAML::Tiny does not modify the input string" );
    SKIP: {
        skip( "Shortcutting after failure", 2 ) if $@;
        isa_ok( $yaml, 'YAML::Tiny' );
        is_deeply( $yaml, $object, "$name: YAML::Tiny parses correctly" );
    }

    # Does the structure serialize to the string.
    # We can't test this by direct comparison, because any
    # whitespace or comments would be lost.
    # So instead we parse back in.
    my $output = eval { $object->write_string };
    is( $@, '', "$name: YAML::Tiny serializes without error" );
    SKIP: {
        skip( "Shortcutting after failure", 5 ) if $@;
        ok(
            !!(defined $output and ! ref $output),
            "$name: YAML::Tiny serializes correctly",
        );
        my $roundtrip = eval { YAML::Tiny->read_string( $output ) };
        is( $@, '', "$name: YAML::Tiny round-trips without error" );
        skip( "Shortcutting after failure", 2 ) if $@;
        isa_ok( $roundtrip, 'YAML::Tiny' );
        is_deeply( $roundtrip, $object, "$name: YAML::Tiny round-trips correctly" );

        # Testing the serialization
        skip( "Shortcutting perfect serialization tests", 1 ) unless $options{serializes};
        is( $output, $string, 'Serializes ok' );
    }

    # Return true as a convenience
    return 1;
}

sub yaml_error {
    my $string = shift;
    my $like   = shift;
    my $yaml   = YAML::Tiny->read_string( $string );
    is( $yaml, undef, '->read_string returns undef' );
    ok( YAML::Tiny->errstr =~ /$like/, "Got expected error" );
    # NOTE: like() gives better diagnostics (but requires 5.005)
    # like( $@, qr/$_[0]/, "YAML::Tiny throws expected error" );
}

sub load_ok {
    my $name = shift;
    my $file = shift;
    my $size = shift;
    ok( -f $file, "Found $name" );
    ok( -r $file, "Can read $name" );
    my $content = slurp( $file, ":encoding(UTF-8)" );
    ok( (defined $content and ! ref $content), "Loaded $name" );
    ok( ($size < length $content), "Content of $name larger than $size bytes" );
    return $content;
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
