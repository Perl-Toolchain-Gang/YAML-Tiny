use strict;
use warnings;
use lib 't/lib/';
use TestMLRun;
use TestMLTiny;

# test a single file C<< perl -Ilib t/02_local_tml.t path/to/test.tml >>
run_testml_files(@ARGV ? @ARGV : testml_all_files('t/tml-local'));
