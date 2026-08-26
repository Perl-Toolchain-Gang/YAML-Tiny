use strict;
use warnings;
use JSON::PP;
use Test::More 0.88;
use YAML::Tiny qw(Load);

my $false = $JSON::PP::false;
my $true  = $JSON::PP::true;

my $yaml = "---
f: false
t: true
ff: \"false\"
tt: \"true\"
n: 10
c: a
";

################################################################################

$YAML::Tiny::Boolean = 1;

my $x = Load($yaml);
cmp_ok($x->{f} , 'eq', $false , "boolean on: false");
cmp_ok($x->{t} , 'eq', $true  , "boolean on: true");
cmp_ok($x->{n} , '==', 10     , "boolean on: num");
cmp_ok($x->{c} , 'eq', 'a'    , "boolean on: char");
cmp_ok($x->{ff}, 'eq', "false", "boolean on: \"false\"");
cmp_ok($x->{tt}, 'eq', "true" , "boolean on: \"true\"");

################################################################################

$YAML::Tiny::Boolean = 0;

$x = Load($yaml);
cmp_ok($x->{f} , 'eq', 'false', "boolean off: false");
cmp_ok($x->{t} , 'eq', 'true' , "boolean off: true");
cmp_ok($x->{n} , '==', 10     , "boolean off: num");
cmp_ok($x->{c} , 'eq', 'a'    , "boolean off: char");
cmp_ok($x->{ff}, 'eq', "false", "boolean off: \"false\"");
cmp_ok($x->{tt}, 'eq', "true" , "boolean off: \"true\"");

################################################################################

done_testing;
