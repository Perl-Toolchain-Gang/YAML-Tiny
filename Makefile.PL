use strict;
BEGIN {
	require 5.003_96;
	$main::VERSION = '1.27';
}
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME      => 'YAML::Tiny',
	ABSTRACT  => 'Read/Write YAML files with as little code as possible',
	VERSION   => $main::VERSION,
	PREREQ_PM => {
		'File::Spec' => '0.80',
		'Test::More' => '0.47',
		($ENV{AUTOMATED_TESTING} ? (
			'YAML'       => '0.62',
			'YAML::Syck' => '0.84',
			'YAML::XS'   => '0.26',
		) : ()),
	},
	($] >= 5.005 ? (
		AUTHOR  => 'Adam Kennedy <adamk@cpan.org>',
	) : ()),
	($ExtUtils::MakeMaker::VERSION ge '6.42' ? (
		LICENSE => 'perl',
	) : ()),
);
