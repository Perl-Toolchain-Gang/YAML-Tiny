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
    yaml_error load_ok
    test_data_directory test_data_file
    json_class slurp
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

sub yaml_error {
    my $string = shift;
    my $like   = shift;
    my $yaml   = YAML::Tiny->read_string( $string );
    is( $yaml, undef, '->read_string returns undef' );
    like( YAML::Tiny->errstr,  qr/$like/, "Got expected error" );
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
    binmode( FILE, $_[0] ) if @_ > 0;
    # binmode(FILE); # disable perl's BOM interpretation
    my $source = <FILE>;
    close( FILE ) or die "close($file) failed: $!";
    $source;
}

1;
