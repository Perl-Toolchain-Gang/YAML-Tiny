# Testing of statements in the YAML-Tiny codebase not exercised elsewhere.
use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;

use File::Spec::Functions ':ALL';
use YAML::Tiny;
use File::Temp qw(tempfile);

# tests for read_string()
{
    my ($obj, $str, $yaml);
    $obj = YAML::Tiny->new();
    isa_ok( $obj, 'YAML::Tiny' );
    $str = join("\n" => ('---', '- foo', '---', '- bar', '---'));
    $str .= "\n";
    eval { $yaml = $obj->read_string($str); };
    ok(! YAML::Tiny->errstr, "\$obj->read_str: No error, as expected");
    isa_ok( $yaml, 'YAML::Tiny' );
    $YAML::Tiny::errstr = '';
}

{
    my ($obj, $str, $yaml);
    $obj = YAML::Tiny->new();
    isa_ok( $obj, 'YAML::Tiny' );
    $str = "--\n";
    eval { $yaml = $obj->read_string($str); };
    like(
        YAML::Tiny->errstr,
        qr/YAML::Tiny found illegal characters in plain scalar/,
        "Illegal characters in plain scalar"
    );
    $YAML::Tiny::errstr = '';
}

{
    my ($obj, $str, $yaml);
    $obj = YAML::Tiny->new();
    isa_ok( $obj, 'YAML::Tiny' );
    $str = join("\n" => ('---', '- foo', '---', '- bar', '---'));
    eval { $yaml = $obj->read_string($str); };
    like(YAML::Tiny->errstr, qr/Stream does not end with newline character/,
        "Got expected error: stream did not end with newline");
    $YAML::Tiny::errstr = '';
}

{
    my ($obj, $str, $yaml);
    $obj = YAML::Tiny->new();
    isa_ok( $obj, 'YAML::Tiny' );
    $str = join("\n" => ('# comment', '---', '- foo', '---', '- bar', '---'));
    $str .= "\n";
    eval { $yaml = $obj->read_string($str); };
    ok(! YAML::Tiny->errstr, "\$obj->read_str: No error, as expected");
    isa_ok( $yaml, 'YAML::Tiny' );
    $YAML::Tiny::errstr = '';
}

{
    my $scalar = 'this is a string';
    my $arrayref = [ 1 .. 5 ];
    my $hashref = { alpha => 'beta', gamma => 'delta' };

    my $yamldump = YAML::Tiny::Dump( $scalar, $arrayref, $hashref );
    my @yamldocsloaded = YAML::Tiny::Load($yamldump);
    is_deeply(
        [ @yamldocsloaded ],
        [ $scalar, $arrayref, $hashref ],
        "Functional interface: Dump to Load roundtrip works as expected"
    );
}

{
    my $scalar = 'this is a string';
    my $arrayref = [ 1 .. 5 ];
    my $hashref = { alpha => 'beta', gamma => 'delta' };

    my ($fh, $filename) = tempfile;
    close $fh; # or LOCK_SH will hang

    my $rv = YAML::Tiny::DumpFile(
        $filename, $scalar, $arrayref, $hashref);
    ok($rv, "DumpFile returned true value");

    my @yamldocsloaded = YAML::Tiny::LoadFile($filename);
    is_deeply(
        [ @yamldocsloaded ],
        [ $scalar, $arrayref, $hashref ],
        "Functional interface: DumpFile to LoadFile roundtrip works as expected"
    );
}

{
    my $str = "This is not real YAML";
    my @yamldocsloaded;
    eval { @yamldocsloaded = YAML::Tiny::Load("$str\n"); };
    like(YAML::Tiny->errstr,
        qr/YAML::Tiny failed to classify line '$str'/,
        "Correctly failed to load non-YAML string"
    );
    $YAML::Tiny::errstr = '';
}

done_testing;
