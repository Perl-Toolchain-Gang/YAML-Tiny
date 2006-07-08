#!/usr/bin/perl -w

# Testing of common META.yml examples

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import(
			catdir('blib', 'lib'),
			catdir('blib', 'arch'),
			'lib'
			);
	}
}

use lib catdir('t', 'lib');
use MyTests;
use Test::More tests(1);
use YAML::Tiny;





#####################################################################
# Example Plagger Configuration from Miyagawa-san's talk

yaml_ok(
	<<'END_YAML',
plugins:
  - module: Subscription::Bloglines
    config:
      username: you@example.pl
      password: foobar
      mark_read: 1

  - module: Publish::Gmail
    config:
      mailto: example@gmail.com
      mailfrom: miyagawa@example.com
      mailroute:
        via: smtp
        host: smtp.example.com
END_YAML
	[ { plugins => [
		{
			module => 'Subscription::Bloglines',
			config => {
				username  => 'you@example.pl',
				password  => 'foobar',
				mark_read => 1,
			},
		},
		{
			module => 'Publish::Gmail',
			config => {
				mailto    => 'example@gmail.com',
				mailfrom  => 'miyagawa@example.com',
				mailroute => {
					via  => 'smtp',
					host => 'smtp.example.com',
				},
			},
		},
	] } ],
	'Plagger',
);

exit(0);
