use strict;
use warnings;
use utf8;

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More 0.90;
use YAML::Tiny;

binmode(Test::More->builder->$_, ":utf8") for qw/output failure_output todo_output/;

subtest "UTF-16-LE BOM fails" => sub {
    my $sample_file = test_data_file('utf_16_le_bom.yml');
    my $yaml      = eval { YAML::Tiny->read( $sample_file ) };
    is( $@, '', "YAML::Tiny read on UTF-16-LE ran without error" );
    is( $yaml, undef, "file not parsed" );
    like(
        YAML::Tiny->errstr,
        qr/Error reading from file.*does not map to Unicode/,
        "correct error"
    );
};

subtest "UTF-8 BOM OK" => sub {
    $YAML::Tiny::errstr = ''; # clear
    my $sample_file = test_data_file('utf_8_bom.yml');
    my $yaml      = eval { YAML::Tiny->read( $sample_file ) };
    is( $@, '', "YAML::Tiny read on UTF-8 with BOM ran without error" );
    is( YAML::Tiny->errstr, '', "YAML::Tiny::errstr empty" );
    is(
        $yaml->[0]{author},
        'Ævar Arnfjörð Bjarmason <avar@cpan.org>',
        "data correct"
    );
};

done_testing;
