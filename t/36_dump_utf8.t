use strict;
use warnings;
use utf8;
use lib 't/lib/';
use Test::More 0.99;
use TestUtils;
use TestBridge;

use YAML::Tiny;
# fixes bug #36
# writch@writch.com


my $scalar = "美国的私有退休金体制\n";

my(%hash);

$hash{'scalar'} = $scalar;
utf8::encode($scalar);
$hash{'scalar_utf'} = $scalar;

my $yaml = YAML::Tiny::Dump(\%hash);
my($t1) = $yaml =~ /scalar: (.*)/;
my($t2) = $yaml =~ /scalar_utf: (.*)/;

ok($t1 eq $t2, "Didn't trash the utf8 encoded stuff");
done_testing();
no warnings;
$DB::single=2;
exit;
