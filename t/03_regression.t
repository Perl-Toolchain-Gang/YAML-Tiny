# Testing of common META.yml examples

use strict;
use warnings;

BEGIN {
    $|  = 1;
    $^W = 1;
}

use File::Spec::Functions ':ALL';
use t::lib::Test;
use Test::More tests => (37 + 13);
use YAML::Tiny qw{
    Load     Dump
    LoadFile DumpFile
    freeze   thaw
};


#####################################################################
# Check Exports

ok( defined(&Load),     'Found exported Load function'     );
ok( defined(&Dump),     'Found exported Dump function'     );
ok( defined(&LoadFile), 'Found exported LoadFile function' );
ok( defined(&DumpFile), 'Found exported DumpFile function' );
ok( defined(&freeze),   'Found exported freeze function'   );
ok( defined(&thaw),     'Found exported thaw functiona'    );


#####################################################################
# Run testml tests:
t::lib::Test::run_testml_file();


#####################################################################
# Circular Reference Protection

SCOPE: {
    my $foo = { a => 'b' };
    my $bar = [ $foo, 2 ];
    $foo->{c} = $bar;
    my $circ = YAML::Tiny->new( [ $foo, $bar ] );
    isa_ok( $circ, 'YAML::Tiny' );

    # When we try to serialize, it should NOT infinite loop
    my $string = undef;
       $string = eval { $circ->write_string; };
    is( $string, undef, '->write_string does not return a value' );
    ok( my $err = YAML::Tiny->errstr, 'Error string is defined' );
    ok(
        $err =~ /does not support circular references/,
        'Got the expected error message',
    );
}


######################################################################
# Check for unescaped boolean keywords

is_deeply(
    YAML::Tiny->new( 'True' )->write_string,
    "--- 'True'\n",
    'Idiomatic trivial boolean string is escaped',
);

is_deeply( YAML::Tiny->new( [ qw{
    null Null NULL
    y Y yes Yes YES n N no No NO
    true True TRUE false False FALSE
    on On ON off Off OFF
} ] )->write_string, <<'END_YAML' );
---
- 'null'
- 'Null'
- 'NULL'
- 'y'
- 'Y'
- 'yes'
- 'Yes'
- 'YES'
- 'n'
- 'N'
- 'no'
- 'No'
- 'NO'
- 'true'
- 'True'
- 'TRUE'
- 'false'
- 'False'
- 'FALSE'
- 'on'
- 'On'
- 'ON'
- 'off'
- 'Off'
- 'OFF'
END_YAML


######################################################################
# Always quote for scalars ending with :

is_deeply(
    YAML::Tiny->new( [ 'A:' ] )->write_string,
    "---\n- 'A:'\n",
    'Simple scalar ending in a colon is correctly quoted',
);
