package t::lib::Test;

use strict;
use warnings;

use Exporter   ();
use File::Spec ();
use Test::More ();

use vars qw{@ISA @EXPORT};
BEGIN {
    @ISA    = qw{ Exporter };
    @EXPORT = qw{
        tests  yaml_ok  yaml_error slurp  load_ok
        test_data_directory test_data_file
    };
    $|  = 1;
    $^W = 1;
}

sub test_data_directory {
    return File::Spec->catdir( 't', 'data' );
}

sub test_data_file {
    return File::Spec->catfile( test_data_directory(), shift );
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
    Test::More::is( $@, '', "$name: YAML::Tiny parses without error" );
    Test::More::is( $yaml_copy, $string, "$name: YAML::Tiny does not modify the input string" );
    SKIP: {
        Test::More::skip( "Shortcutting after failure", 2 ) if $@;
        Test::More::isa_ok( $yaml, 'YAML::Tiny' );
        Test::More::is_deeply( $yaml, $object, "$name: YAML::Tiny parses correctly" );
    }

    # Does the structure serialize to the string.
    # We can't test this by direct comparison, because any
    # whitespace or comments would be lost.
    # So instead we parse back in.
    my $output = eval { $object->write_string };
    Test::More::is( $@, '', "$name: YAML::Tiny serializes without error" );
    SKIP: {
        Test::More::skip( "Shortcutting after failure", 5 ) if $@;
        Test::More::ok(
            !!(defined $output and ! ref $output),
            "$name: YAML::Tiny serializes correctly",
        );
        my $roundtrip = eval { YAML::Tiny->read_string( $output ) };
        Test::More::is( $@, '', "$name: YAML::Tiny round-trips without error" );
        Test::More::skip( "Shortcutting after failure", 2 ) if $@;
        Test::More::isa_ok( $roundtrip, 'YAML::Tiny' );
        Test::More::is_deeply( $roundtrip, $object, "$name: YAML::Tiny round-trips correctly" );

        # Testing the serialization
        Test::More::skip( "Shortcutting perfect serialization tests", 1 ) unless $options{serializes};
        Test::More::is( $output, $string, 'Serializes ok' );
    }

    # Return true as a convenience
    return 1;
}

sub yaml_error {
    my $string = shift;
    my $like   = shift;
    my $yaml   = YAML::Tiny->read_string( $string );
    Test::More::is( $yaml, undef, '->read_string returns undef' );
    Test::More::ok( YAML::Tiny->errstr =~ /$like/, "Got expected error" );
    # NOTE: like() gives better diagnostics (but requires 5.005)
    # Test::More::like( $@, qr/$_[0]/, "YAML::Tiny throws expected error" );
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

sub load_ok {
    my $name = shift;
    my $file = shift;
    my $size = shift;
    Test::More::ok( -f $file, "Found $name" );
    Test::More::ok( -r $file, "Can read $name" );
    my $content = slurp( $file, ":encoding(UTF-8)" );
    Test::More::ok( (defined $content and ! ref $content), "Loaded $name" );
    Test::More::ok( ($size < length $content), "Content of $name larger than $size bytes" );
    return $content;
}

sub run_testml_file {
    my ($plan) = @_;
    local @INC = ('lib', 't/lib', @INC);
    require TestMLTiny;
    TestMLTiny->import;
    require YAML::Tiny;

    my (undef, $testml_file) = caller;
    $testml_file .= 'ml';
    testml_run_file(
        $testml_file,
        sub {
            my ($block) = @_;
            my ($label, $yaml, $perl) =
                @{$block}{qw(Label yaml perl)};
            $perl = eval $perl; die $@ if $@;
            my %flags = ();
            for (qw(noyamlpm nosyck noxs)) {
                if (defined($block->{$_})) {
                    $flags{$_} =1;
                }
            }

            Test::More::subtest "$block->{Label}", sub {
                yaml_ok($yaml, $perl, $label, %flags);
            };
        }
    );
}

1;
