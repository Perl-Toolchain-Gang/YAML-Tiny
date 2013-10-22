#!perl

use Test::More;
use YAML::Tiny;
use JSON::PP;
use XXX;
# skip_all if no json on old perl

(my $d = __FILE__) =~ s/\.t$//g;

opendir my $dh, $d or die;
while (my $t = readdir($dh)) {
    next if $t =~ /^\.\.?$/;
    process_test("$d/$t");
}

sub process_test {
    my ($t) = @_;
    if (-f (my $yf = "$t/yaml")) {
        my $y = slurp($yf);
        my $o = eval {
            Load $y;
        };
        ok !$@, "$yf loads";
        next if $@;
        if (-f (my $jf= "$t/json")) {
            my $j = slurp($jf);
            chomp $j;
            my $want = $j;
            my $got = encode_json $o;
            is $got, $want, "$yf loads correctly";
        }

    }

}

sub slurp { local $/; open(my $fh, '<', shift); <$fh>; }

done_testing;
