use strict;
BEGIN {
	require 5.003_96;
	$main::VERSION = '1.37';
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
			'YAML'       => '0.68',
			'YAML::Perl' => '0.02',
			'YAML::Syck' => '1.07',
			'YAML::XS'   => '0.29',
		) : ()),
	},
	($] >= 5.005 ? (
		AUTHOR  => 'Adam Kennedy <adamk@cpan.org>',
	) : ()),
	($ExtUtils::MakeMaker::VERSION ge '6.42' ? (
		LICENSE => 'perl',
	) : ()),
);
