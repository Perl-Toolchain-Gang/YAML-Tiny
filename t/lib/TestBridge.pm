package TestBridge;

use strict;
use warnings;

use Test::More 0.99;
use TestUtils;
use TestMLTiny;

use YAML::Tiny;

use Exporter   ();
our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    test_yaml_json
    test_yaml_perl
    test_code_point
    test_local
    error_like
};

my %ERROR = (
    E_CIRCULAR => qr{\QYAML::Tiny does not support circular references},
    E_FEATURE  => qr{\QYAML::Tiny does not support a feature},
    E_PLAIN    => qr{\QYAML::Tiny found illegal characters in plain scalar},
);

# use XXX -with => 'YAML::XS';

my %DISPATCH = (
    "yaml perl" => \&test_yaml_perl,
    "dump yaml" => \&test_dump_yaml,
    "dump error" => \&test_dump_error,
    "yaml error" => \&test_yaml_error,
);

sub error_like {
    my ($regex, $label) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    like( YAML::Tiny->errstr, $regex, "Got expected error" );
    $YAML::Tiny::errstr = ''; # reset it
}

sub test_local {
    my ($block) = @_;

    while ( my ( $spec, $code ) = each %DISPATCH ) {
        my @points = testml_has_points($block, split " ", $spec);
        $code->($block, @points) if @points;
    }
}

sub test_yaml_perl {
    my ($block) = @_;

    my ($yaml, $perl, $label) =
      testml_has_points($block, qw(yaml perl)) or return;

    my %options = ();
    for (qw(serializes)) {
        if (defined($block->{$_})) {
            $options{$_} = 1;
        }
    }

    my $expected = eval $perl; die $@ if $@;
    bless $expected, 'YAML::Tiny';

    subtest $label, sub {
        # Does the string parse to the structure
        my $yaml_copy = $yaml;
        my $got       = eval { YAML::Tiny->read_string( $yaml_copy ); };
        is( $@, '', "YAML::Tiny parses without error" );
        is( $yaml_copy, $yaml, "YAML::Tiny does not modify the input string" );
        SKIP: {
            skip( "Shortcutting after failure", 2 ) if $@;
            isa_ok( $got, 'YAML::Tiny' );
            is_deeply( $got, $expected, "YAML::Tiny parses correctly" )
                or diag "ERROR: $YAML::Tiny::errstr";
        }

        # Does the structure serialize to the string.
        # We can't test this by direct comparison, because any
        # whitespace or comments would be lost.
        # So instead we parse back in.
        my $output = eval { $expected->write_string };
        is( $@, '', "YAML::Tiny serializes without error" );
        SKIP: {
            skip( "Shortcutting after failure", 5 ) if $@;
            ok(
                !!(defined $output and ! ref $output),
                "YAML::Tiny serializes to scalar",
            );
            my $roundtrip = eval { YAML::Tiny->read_string( $output ) };
            is( $@, '', "YAML::Tiny round-trips without error" );
            skip( "Shortcutting after failure", 2 ) if $@;
            isa_ok( $roundtrip, 'YAML::Tiny' );
            is_deeply( $roundtrip, $expected, "YAML::Tiny round-trips correctly" );

            # Testing the serialization
            skip( "Shortcutting perfect serialization tests", 1 ) unless $options{serializes};
            is( $output, $yaml, 'Serializes ok' );
        }

    };
}

sub test_dump_yaml {
    my ($block, $dump, $yaml, $label) = @_;

    my $input = eval "no strict; $dump"; die $@ if $@;

    subtest $label, sub {
        my $result = eval { YAML::Tiny->new( $input )->write_string };
        is( $@, '', "write_string lives" );
        is( $result, $yaml, "dumped YAML correct" );
    };
}

sub test_dump_error {
    my ($block, $dump, $error, $label) = @_;

    my $input = eval "no strict; $dump"; die $@ if $@;
    chomp $error;
    my $expected = $ERROR{$error};

    subtest $label, sub {
        my $result = eval { YAML::Tiny->new( $input )->write_string };
        is( $@, '', "write_string lives" );
        ok( !$result, "returned false" );
        error_like( $expected, "Got expected error" );
    };
}

sub test_yaml_error {
    my ($block, $yaml, $error, $label) = @_;

    chomp $error;
    my $expected = $ERROR{$error};

    subtest $label, sub {
        my $result = eval { YAML::Tiny->read_string( $yaml ) };
        is( $@, '', "read_string lives" );
        is( $result, undef, 'read_string returns undef' );
        error_like( $expected, "Got expected error" );
    };
}

sub test_yaml_json {
    my ($block, $json_lib) = @_;
    $json_lib ||= do { require JSON::PP; 'JSON::PP' };

    my ($yaml, $json, $label) =
      testml_has_points($block, qw(yaml json)) or return;

    subtest "$label", sub {
        # test YAML Load
        my $object = eval {
            YAML::Tiny::Load($yaml);
        };
        my $err = $@;
        ok !$err, "YAML loads";
        return if $err;

        # test YAML->Perl->JSON
        # N.B. round-trip JSON to decode any \uNNNN escapes and get to
        # characters
        my $want = $json_lib->new->encode(
            $json_lib->new->decode($json)
        );
        my $got = $json_lib->new->encode($object);
        is $got, $want, "Load is accurate";
    };
}

sub test_code_point {
    my ($block) = @_;

    my ($code, $yaml, $label) =
        testml_has_points($block, qw(code yaml)) or return;

    subtest "$label - Unicode map key/value test" => sub {
        my $data = { chr($code) => chr($code) };
        my $dump = YAML::Tiny::Dump($data);
        $dump =~ s/^---\n//;
        is $dump, $yaml, "Dump key and value of code point char $code";

        my $yny = YAML::Tiny::Dump(YAML::Tiny::Load($yaml));
        $yny =~ s/^---\n//;
        is $yny, $yaml, "YAML for code point $code YNY roundtrips";

        my $nyn = YAML::Tiny::Load(YAML::Tiny::Dump($data));
        is_deeply $nyn, $data, "YAML for code point $code NYN roundtrips";
    }
}

1;
