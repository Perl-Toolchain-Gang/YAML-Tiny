use strict;
use warnings;
use lib 't/lib/';
use Test::More 0.88;
use File::Temp qw(tempfile);

use YAML::Tiny qw(Load LoadFile Dump DumpFile);

my $single_doc = "---\nfoo: bar\n";
my $multi_doc  = "---\nfoo: bar\n---\n- baz\n";

# Single document in scalar context: no warning
{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };

    my $result = Load($single_doc);
    is_deeply($result, { foo => 'bar' }, 'single doc scalar context returns correctly');
    is(scalar @warnings, 0, 'no warning for single document in scalar context');
}

# Multiple documents in list context: no warning
{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };

    my @result = Load($multi_doc);
    is(scalar @result, 2, 'multi doc list context returns all documents');
    is_deeply($result[0], { foo => 'bar' }, 'first document correct');
    is_deeply($result[1], [ 'baz' ], 'second document correct');
    is(scalar @warnings, 0, 'no warning for multiple documents in list context');
}

# Multiple documents in scalar context: warning emitted
{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };

    my $result = Load($multi_doc);
    is_deeply($result, [ 'baz' ], 'multi doc scalar context returns last document');
    is(scalar @warnings, 1, 'one warning for multiple documents in scalar context');
    like(
        $warnings[0],
        qr/YAML::Tiny::Load called in scalar context.*multiple YAML documents/,
        'warning message is descriptive',
    );
}

# LoadFile: multiple documents in scalar context
{
    my ($fh, $tmpfile) = tempfile(UNLINK => 1, SUFFIX => '.yml');
    print $fh $multi_doc;
    close $fh;

    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };

    my $result = LoadFile($tmpfile);
    is_deeply($result, [ 'baz' ], 'LoadFile multi doc scalar context returns last document');
    is(scalar @warnings, 1, 'one warning from LoadFile for multiple documents in scalar context');
    like(
        $warnings[0],
        qr/YAML::Tiny::LoadFile called in scalar context.*multiple YAML documents/,
        'LoadFile warning message is descriptive',
    );
}

# LoadFile: single document in scalar context: no warning
{
    my ($fh, $tmpfile) = tempfile(UNLINK => 1, SUFFIX => '.yml');
    print $fh $single_doc;
    close $fh;

    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };

    my $result = LoadFile($tmpfile);
    is_deeply($result, { foo => 'bar' }, 'LoadFile single doc scalar context returns correctly');
    is(scalar @warnings, 0, 'no warning from LoadFile for single document');
}

done_testing;
