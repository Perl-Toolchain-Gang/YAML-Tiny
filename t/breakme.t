use Test::Base tests => 10;
use YAML::Tiny;

delimiters('===', '+++');
filters({perl => 'tiny_dump'});

run_is perl => 'yaml';
run_is perl => 'error';

sub tiny_dump {
    my @objects = eval shift;
    return $@ if $@;
    my $yaml;
    eval {
        $yaml = Dump(eval($_));
    };
    return $@ if $@;
    return $yaml;
}

__DATA__
=== String of blanks
+++ perl
"  ";
+++ yaml
--- "  "

=== Leading  and trailing blanks
+++ perl
("  foo", "bar  ");
+++ yaml
--- "  foo"
--- "bar  "

=== A newline
+++ perl
"\n"
+++ yaml
--- "\n"

=== YAML in YAML
+++ perl
<<END

---
foo: bar
END
+++ yaml
--- "\n---\nfoo: bar\n"

=== A simple array
+++ perl
[1,2,3]
+++ yaml
---
- 1
- 2
- 3

=== Blessed Stuff
+++ perl
bless ["u"], "MySon";
+++ error
YAML::Tiny don't do blessed stuff

=== Cycles (ooops!!!)
+++ perl
$a = {}; $a->{foo} = $a; $a;
+++ error
YAML::Tiny don't do loopy stuff
