#!/usr/bin/perl -w

# Testing Plagger config samples from Miyagawa-san's YAPC::NA 2006 talk

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
use Test::More tests(2);
use YAML::Tiny;





#####################################################################
# Example Plagger Configuration 1

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





#####################################################################
# Example Plagger Configuration 2

yaml_ok(
	<<'END_YAML',
plugins:
 - module: Subscription::Config
   config:
     feed:
        # Trac's feed for changesets
        - http://plagger.org/.../rss

 # I don't like to be notified of the same items
 # more than once
 - module: Filter::Rule
   rule:
     module: Fresh
     mtime:
       path: /tmp/rssbot.time
       autoupdate: 1

 - module: Notify::IRC
   config:
     daemon_port: 9999
     nickname: plaggerbot
     server_host: chat.freenode.net
     server_channels:
       - #plagger-ja
       - #plagger

   
END_YAML
	[ { plugins => [ {
		module => 'Subscription::Config',
		config => {
			feed => [ 'http://plagger.org/.../rss' ],
		},
	}, {
		module => 'Filter::Rule',
		rule   => {
			module => 'Fresh',
			mtime  => {
				path => '/tmp/rssbot.time',
				autoupdate => 1,
			},
		},
	}, {
		module => 'Notify::IRC',
		config => {
			daemon_port     => 9999,
			nickname        => 'plaggerbot',
			server_host     => 'chat.freenode.net',
			server_channels => [
				'#plagger-ja',
				'#plagger',
			],
		},
	} ] } ],
	'plagger2',
);			

exit(0);
