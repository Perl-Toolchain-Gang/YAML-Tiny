use strict;
use warnings;
use Test::More 0.88;
use YAML::Tiny ();

#--------------------------------------------------------------------------#
# Test classes with TO_JSON support
#--------------------------------------------------------------------------#

{
    package My::HashObj;
    sub new { bless { value => $_[1] }, $_[0] }
    sub TO_JSON { { value => $_[0]->{value} } }
}

{
    package My::ArrayObj;
    sub new { bless [ @_[1..$#_] ], $_[0] }
    sub TO_JSON { [ @{ $_[0] } ] }
}

{
    package My::StringObj;
    sub new { bless \(my $s = $_[1]), $_[0] }
    sub TO_JSON { ${ $_[0] } }
}

{
    package My::NoJSON;
    sub new { bless { x => 1 }, $_[0] }
}

#--------------------------------------------------------------------------#
# Root-level document tests
#--------------------------------------------------------------------------#

subtest 'blessed hash object with TO_JSON at root' => sub {
    my $obj  = My::HashObj->new('hello');
    my $yaml = YAML::Tiny->new($obj)->write_string;
    is( $yaml, "---\nvalue: hello\n", "serializes TO_JSON hash result at root" );
};

subtest 'blessed hash object without TO_JSON at root dies' => sub {
    my $obj    = My::NoJSON->new;
    my $result = eval { YAML::Tiny->new($obj)->write_string };
    ok( !$result, "returns false" );
    like( $@, qr/Cannot serialize/, "got expected error" );
};

#--------------------------------------------------------------------------#
# Object inside an array
#--------------------------------------------------------------------------#

subtest 'blessed hash object with TO_JSON in array' => sub {
    my $obj  = My::HashObj->new('world');
    my $yaml = YAML::Tiny->new( [$obj] )->write_string;
    is( $yaml, "---\n-\n  value: world\n", "serializes TO_JSON in array element" );
};

subtest 'blessed array object with TO_JSON in array' => sub {
    my $obj  = My::ArrayObj->new( 'a', 'b' );
    my $yaml = YAML::Tiny->new( [$obj] )->write_string;
    is( $yaml, "---\n-\n  - a\n  - b\n", "serializes TO_JSON array result in array" );
};

subtest 'blessed scalar object with TO_JSON in array' => sub {
    my $obj  = My::StringObj->new('simple');
    my $yaml = YAML::Tiny->new( [$obj] )->write_string;
    is( $yaml, "---\n- simple\n", "serializes TO_JSON scalar result in array" );
};

subtest 'blessed object without TO_JSON in array dies' => sub {
    my $obj    = My::NoJSON->new;
    my $result = eval { YAML::Tiny->new( [$obj] )->write_string };
    ok( !$result, "returns false" );
    like( $@, qr/does not support/, "got expected error" );
};

#--------------------------------------------------------------------------#
# Object as a hash value
#--------------------------------------------------------------------------#

subtest 'blessed hash object with TO_JSON as hash value' => sub {
    my $obj  = My::HashObj->new('there');
    my $yaml = YAML::Tiny->new( { key => $obj } )->write_string;
    is( $yaml, "---\nkey:\n  value: there\n", "serializes TO_JSON in hash value" );
};

subtest 'blessed scalar object with TO_JSON as hash value' => sub {
    my $obj  = My::StringObj->new('str_val');
    my $yaml = YAML::Tiny->new( { key => $obj } )->write_string;
    is( $yaml, "---\nkey: str_val\n", "serializes TO_JSON scalar as hash value" );
};

subtest 'blessed object without TO_JSON as hash value dies' => sub {
    my $obj    = My::NoJSON->new;
    my $result = eval { YAML::Tiny->new( { key => $obj } )->write_string };
    ok( !$result, "returns false" );
    like( $@, qr/does not support/, "got expected error" );
};

done_testing;
