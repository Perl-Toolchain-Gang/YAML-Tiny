use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.99;
use TestBridge;
use File::Temp qw(tempfile);

#--------------------------------------------------------------------------#
# This file test that the YAML.pm compatible Dump/Load/DumpFile/LoadFile
# work as documented
#--------------------------------------------------------------------------#

use YAML::Tiny;

{
    my $scalar = 'this is a string';
    my $arrayref = [ 1 .. 5 ];
    my $hashref = { alpha => 'beta', gamma => 'delta' };

    my $yamldump = YAML::Tiny::Dump( $scalar, $arrayref, $hashref );
    my @yamldocsloaded = YAML::Tiny::Load($yamldump);
    cmp_deeply(
        [ @yamldocsloaded ],
        [ $scalar, $arrayref, $hashref ],
        "Functional interface: Dump to Load roundtrip works as expected"
    );
}

{
    my $scalar = 'this is a string';
    my $arrayref = [ 1 .. 5 ];
    my $hashref = { alpha => 'beta', gamma => 'delta' };

    my ($fh, $filename) = tempfile("YAML-Tiny-test-XXXXXXXX", TMPDIR => 1, UNLINK=>1);
    close $fh; # or LOCK_SH will hang

    my $rv = YAML::Tiny::DumpFile(
        $filename, $scalar, $arrayref, $hashref);
    ok($rv, "DumpFile returned true value");

    my @yamldocsloaded = YAML::Tiny::LoadFile($filename);
    cmp_deeply(
        [ @yamldocsloaded ],
        [ $scalar, $arrayref, $hashref ],
        "Functional interface: DumpFile to LoadFile roundtrip works as expected"
    );
}

{
    my $str = "This is not real YAML";
    my @yamldocsloaded;
    eval { @yamldocsloaded = YAML::Tiny::Load("$str\n"); };
    error_like(
        qr/YAML::Tiny failed to classify line '$str'/,
        "Correctly failed to load non-YAML string"
    );
}

done_testing;
