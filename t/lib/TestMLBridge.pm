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
};

sub test_yaml_perl {
    my ($block) = @_;
    my ($label, $yaml, $perl) =
        @{$block}{qw(Label yaml perl)};
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
    my ($block, $json, $yaml) = @_;

    testml_has_points($block, qw(yaml json)) or return;

    my $loader = do { no strict 'refs'; \&{"${yaml}::Load"} };

    subtest "$block->{Label}", sub {
        # test YAML Load
        my $object = eval {
            $loader->($block->{yaml});
        };
        my $err = $@;
        ok !$err, "YAML loads";
        return if $err;

        # test YAML->Perl->JSON
        # N.B. round-trip JSON to decode any \uNNNN escapes and get to
        # characters
        my $want = $json->new->encode($json->new->decode($block->{json}));
        my $got = $json->new->encode($object);
        is $got, $want, "Load is accurate";
    };
}

1;
