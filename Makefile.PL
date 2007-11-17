use strict;
BEGIN {
	require 5.003_96;
	$main::VERSION = '1.19';
}
use ExtUtils::MakeMaker;

my $PREREQ_PM = {
	'File::Spec' => '0.80',
	'Test::More' => '0.47',
};
if ( $ENV{AUTOMATED_TESTING} ) {
	$PREREQ_PM->{'YAML'}       = '0.62';
	$PREREQ_PM->{'YAML::Syck'} = '0.84';
}

WriteMakefile(
	NAME      => 'YAML::Tiny',
	ABSTRACT  => 'Read/Write YAML files with as little code as possible',
	VERSION   => $main::VERSION,
	PREREQ_PM => $PREREQ_PM,
	($] >= 5.005 ? (
		AUTHOR  => 'Adam Kennedy <adamk@cpan.org>',
	) : ()),
	($ExtUtils::MakeMaker::VERSION ge '6.30_00' ? (
		LICENSE => 'perl',
	) : ()),
);

