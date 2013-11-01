package xt::lib::Test;

use strict;
use warnings;

use Exporter   ();

our @ISA    = qw{ Exporter };
our @EXPORT = qw{
    have_yamlpm
    have_yamlsyck
    have_yamlxs
};

# Do we have the authorative YAML to test against
eval {
    require YAML;

    # This doesn't currently work, but is documented to.
    # So if it ever turns up, use it.
    $YAML::UseVersion = 1;
};
my $HAVE_YAMLPM = !! (
    $YAML::VERSION
    and
    $YAML::VERSION >= 0.66
);
sub have_yamlpm { $HAVE_YAMLPM }

# Do we have YAML::Syck to test against?
eval {
    require YAML::Syck;
};
my $HAVE_SYCK = !! (
    $YAML::Syck::VERSION
    and
    $YAML::Syck::VERSION >= 1.05
);
sub have_yamlsyck { $HAVE_SYCK }

# Do we have YAML::XS to test against?
eval {
    require YAML::XS;
};
my $HAVE_XS = !! (
    $YAML::XS::VERSION
    and
    $YAML::XS::VERSION >= 0.29
);
sub have_yamlxs{ $HAVE_XS }

1;
