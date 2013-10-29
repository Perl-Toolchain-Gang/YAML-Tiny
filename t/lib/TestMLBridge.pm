package TestMLBridge;

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
};


# use XXX -with => 'YAML::XS';


sub test_yaml_perl {
    my ($block) = @_;
    my ($yaml, $perl, $label) =
      testml_has_points($block, qw(yaml perl)) or return;
    $perl = eval $perl; die $@ if $@;
    my %flags = ();
    for (qw(serializes)) {
        if (defined($block->{$_})) {
            $flags{$_} = 1;
        }
    }

    subtest "$block->{Label}", sub {
        yaml_ok($yaml, $perl, $label, %flags);
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
