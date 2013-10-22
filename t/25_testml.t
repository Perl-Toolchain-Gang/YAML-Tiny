use strict;
use warnings;
use lib 't/lib';
use TestMLTiny;
use YAML::Tiny;

my $JSON = testml_require_json_or_skip_all;

sub main {
    for my $file (testml_all_files('t/testml')) {
        note "YAML Spec Test File: $file";
        testml_run_file($file, \&test_yaml_load);
#         # Run files as subtest:
#         subtest "YAML Spec Test File: $file",
#             sub { testml_run_file($file, \&test_yaml_load) };
    }
    done_testing;
}

sub test_yaml_load {
    my ($block) = @_;

    testml_has_points($block, qw(yaml json)) or return;

    subtest "$block->{Label}", sub {
        # test YAML Load
        my $object = eval {
            YAML::Tiny::Load $block->{yaml};
        };
        my $err = $@;
        ok !$err, "YAML loads";
        return if $err;

        # test YAML->Perl->JSON
        # N.B. round-trip JSON to decode any \uNNNN escapes and get to characters
        my $want = $JSON->new->encode($JSON->new->decode($block->{json}));
        my $got = $JSON->new->encode($object);
        is $got, $want, "Load is accurate";
    };
}

main @ARGV;
