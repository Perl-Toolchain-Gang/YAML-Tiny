package YAML::Tiny;

# YAML, but just the best bits

use 5.004;
use strict;

use vars qw{$VERSION $errstr};
BEGIN {
	$VERSION = '0.01';
	$errstr  = '';
}

# Create the main error hash
my %ERROR = (
	YAML_PARSE_ERR_NO_FINAL_NEWLINE => "Stream does not end with newline character",
);

my %NO = (
	'#' => 'YAML::Tiny does not support partial-line comments',
	'%' => 'YAML::Tiny does not support directives',
	'&' => 'YAML::Tiny does not support anchors',
	'*' => 'YAML::Tiny does not support aliases',
	'?' => 'YAML::Tiny does not support explicit mapping keys',
	':' => 'YAML::Tiny does not support explicit mapping values',
	'|' => 'YAML::Tiny does not support literal multi-line scalars',
	'>' => 'YAML::Tiny does not support folded multi-line scalars',
	'!' => 'YAML::Tiny does not support explicit tags',
	"'" => 'YAML::Tiny does not support quoted strings',
	'"' => 'YAML::Tiny does not support quoted strings',
);

use constant FILE       => 0;
use constant START      => 1;
use constant ARRAY      => 2;
use constant OPEN_ARRAY => 3;

# Create an empty YAML::Tiny object
sub new {
	bless [], shift;
}

# Create an object from a file
sub read {
	my $class = ref $_[0] ? ref shift : shift;

	# Check the file
	my $file = shift or return $class->_error( 'You did not specify a file name' );
	return $class->_error( "File '$file' does not exist" )              unless -e $file;
	return $class->_error( "'$file' is a directory, not a file" )       unless -f _;
	return $class->_error( "Insufficient permissions to read '$file'" ) unless -r _;

	# Slurp in the file
	local $/ = undef;
	open CFG, $file or return $class->_error( "Failed to open file '$file': $!" );
	my $contents = <CFG>;
	close CFG;

	$class->read_string( $contents );
}

# Create an object from a string
sub read_string {
	my $class = ref $_[0] ? ref shift : shift;
	my $self  = bless [], $class;

	# Handle special cases
	return undef unless defined $_[0];
	return $self unless length  $_[0];
	unless ( $_[0] =~ /[\012\015]+$/ ) {
		return $class->_error('YAML_PARSE_ERR_NO_FINAL_NEWLINE');
	}

	# State variables
	my $line     = 0;
	my $state    = FILE;
	my $document = undef;
	my @indents  = ( );
	my @cursors  = ( );

	foreach ( split /(?:\015{1,2}\012|\015|\012)/, shift ) {
		$line++;

		# Skip comments and empty lines
		next if /^\s*(?:\#|$)/;

		# Get the indent level for the line
		my $indent = s/^(\s+)// ? length($1) : 0;

		# Check for a document header
		if ( s/^(---(?:\s+|\Z))// ) {
			if ( $state == FILE ) {
				$state = START;
			} else {
				# Change to new document
				push @$self, $document;
				$document = undef;
				$state    = START;
			}
			next unless length $_;
			my $c = substr($_, 0, 1);
			return $class->_error($NO{$c}) if $NO{$c};

			# Assume a scalar
			$document = $self->_read_scalar($_);

			next;
		}

		# Are we in START mode, expecting a list or hash
		if ( $state == START ) {
			my $c = substr($_,0,1);
			return $class->_error($NO{$c}) if $NO{$c};
			if ( s/^(-(?:\s+|\Z))// ) {
				# We have an ARRAY
				$document = [ ];
				push @indents, $indent;
				push @cursors, $document;
				unless ( length $_ ) {
					# Open array
					$state = OPEN_ARRAY;
					next;
				}
				$c = substr($_, 0, 1);
				return $class->_error($NO{$c}) if $NO{$c};

				# Assume a scalar
				push @$document, $self->_read_scalar($_);
				$state = ARRAY;
				next;
			}
		}

		# Are we in ARRAY mode, expecting the next array element
		if ( $state == ARRAY ) {
			my $c = substr($_,0,1);
			return $class->_error($NO{$c}) if $NO{$c};
			if ( s/^(-(?:\s+|\Z))// ) {
				# We have an ARRAY
				### Assume for now we are at the same indent level
				unless ( length $_ ) {
					# Open array
					$state = OPEN_ARRAY;
					next;
				}
				$c = substr($_, 0, 1);
				return $class->_error($NO{$c}) if $NO{$c};

				# Assume a scalar
				push @$document, $self->_read_scalar($_);
				next;
			}
		}

		die "CODE INCOMPLETE";
	}

	# Save final document
	push @$self, $document unless $state == FILE;

	$self;
}

# Deparse a scalar string to the actual scalar
sub _read_scalar {
	my $self   = shift;
	my $string = shift;
	return undef if $string eq '~';
	return $string;
}

# Save an object to a file
sub write {
	my $self = shift;
	my $file = shift or return $self->_error(
		'No file name provided'
		);

	# Write it to the file
	open( CFG, '>' . $file ) or return $self->_error(
		"Failed to open file '$file' for writing: $!"
		);
	print CFG $self->write_string;
	close CFG;
}

# Save an object to a string
sub write_string {
	my $self = shift;
	return '' unless @$self;

	# Iterate over the documents
	my @lines = ();
	foreach my $document ( @$self ) {
		# Special cases
		unless ( defined $document ) {
			push @lines, '---';
			next;
		}
		unless ( ref $document ) {
			push @lines, "--- $document";
			next;
		}

		# Handle a plain list
		if ( ref($document) eq 'ARRAY' ) {
			push @lines, '---';
			push @lines, map { "- $_" } @$document;
			next;
		}

		die "CODE INCOMPLETE";
	}

	join '', map { "$_\n" } @lines;
}

# Set error
sub _error {
	$errstr = $ERROR{$_[1]} ? "$ERROR{$_[1]} ($_[1])" : $_[1];
	undef;
}

# Retrieve error
sub errstr {
	$errstr;
}


1;

__END__

=pod

=head1 NAME

YAML::Tiny - Read/Write YAML files with as little code as possible

=head1 PREAMBLE

B<WARNING: THIS MODULES IS HIGHLY EXPERIMENTAL AND SUBJECT TO CHANGE
WITHOUT NOTICE>

The YAML specification is huge. Like, B<really> huge. It contains all the
functionality of XML, except with flexibility and choice, which makes the
full specification more complex than XML.

The pure-Perl implementation L<YAML> costs just over 4 megabytes of memory
to load. Just like with Windows .ini files (3 meg to load) and CSS (3.5 meg
to load) the situation is just asking for B<YAML::Tiny> module, to implement
a incomplete but usable subset of the functionality, in as little code as
possible.

Now, given the YAML features one would need in order to have something
that is usable for things like META.yml and simple configuration files,
there's still enough complexity that I'm not sure if it is even possible
to do a YAML::Tiny module.

So I'm going to impose some ground rules.

Like the other C<::Tiny> modules, YAML::Tiny will have no non-core
dependencies, and work back to at least perl 5.005_03, hopefully 5.004.

I'm setting a hard-limit of 400k of memory (1/10th of YAML.pm).

I plan to implement features from the most common to the least common, but
if we hit 400k limit then we stop until we can find a way to squish the
same functionality into less code and free some up.

At this point, other than unquoted scalars, arrays, hashes and ASCII,
I promise nothing.

At present I've (literally) cut-and-pasted a L<Config::Tiny>-like set of
methods, and I've implemented enough code to handle the following.

  # A comment
  ---
  - foo
  - bar

And that's it. So do B<not> use this module for anything other than
experimentation. It's only just getting started.

=head1 SYNOPSIS

    #############################################
    # In your file
    
    ---
    rootproperty: blah
    section:
      one: two
      three: four
      Foo: Bar
      empty: ~
    
    #############################################
    # In your program
    
    use YAML::Tiny;
    
    # Create a YAML file
    my $yaml = YAML::Tiny->new;
    
    # Open the config
    $yaml = YAML::Tiny->read( 'file.yml' );
    
    # Reading properties
    my $root = $yaml->[0]->{rootproperty};
    my $one  = $yaml->[0]->{section}->{one};
    my $Foo  = $yaml->[0]->{section}->{Foo};
    
    # Changing data
    $yaml->[0]->{newsection} = { this => 'that' }; # Add a section
    $yaml->[0]->{section}->{Foo} = 'Not Bar!';     # Change a value
    delete $yaml->[0]->{section};                  # Delete a value or section
    
    # Add an entire document
    $yaml->[1] = [ 'foo', 'bar', 'baz' ];
    
    # Save the file
    $yaml->write( 'file.conf' );

=head1 DESCRIPTION

C<Config::Tiny> is a perl class to read and write YAML-style files with as
little code as possible, reducing load time and memory overhead.

Most of the time it is accepted that Perl applications use a lot
of memory and modules. The C<::Tiny> family of modules is specifically
intended to provide an ultralight alternative to the standard modules.

This module is primarily for reading human written files (like config files)
and generating simple human-readable report. Note that I said
B<human-readable> and not B<geek-readable>. The sort of files that your
average manager or secretary should be able to look at and make sense of.

L<YAML::Tiny> does not generate comments, it won't necesarily preserve the
order of your hashs, and it may normalise if reading in and writing out
again.

It only supports a very basic subset of the full YAML specification.

It is also targetted at files like Perl's META.yml, for which a small and
easily-embeddable module would be highly useful.

Features will only be added if they are human readable, and can be written
in a few lines of code. Please don't be offended if your request is
refused. Someone has to draw the line, and for YAML::Tiny that someone is
the module author.

If you need something with more power move up to L<YAML> (4 megabytes of\
memory overhead) or L<YAML::Syck> (requires libsyck).

To restate, L<YAML::Tiny> does B<not> preserve your comments, whitespace, or
the order of your YAML data. But it should round-trip from Perl structure
to file and back again just fine.

=head1 METHODS

=head2 new

The constructor C<new> creates and returns an empty C<Config::Tiny> object.

=head2 read $filename

The C<read> constructor reads a YAML file, and returns a new
C<YAML::Tiny> object containing the contents of the file. 

Returns the object on success, or C<undef> on error.

When C<read> fails, C<YAML::Tiny> sets an error message internally
you can recover via C<<YAML::Tiny->errstr>>. Although in B<some>
cases a failed C<read> will also set the operating system error
variable C<$!>, not all errors do and you should not rely on using
the C<$!> variable.

=head2 read_string $string;

The C<read_string> method takes as argument the contents of a YAML file
(a YAML document) as a string and returns the C<YAML::Tiny> object for
it.

=head2 write $filename

The C<write> method generates the file content for the properties, and
writes it to disk to the filename specified.

Returns true on success or C<undef> on error.

=head2 write_string

Generates the file content for the object and returns it as a string.

=head2 errstr

When an error occurs, you can retrieve the error message either from the
C<$YAML::Tiny::errstr> variable, or using the C<errstr()> method.

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=YAML-Tiny>

For other issues, or commercial enhancement or support, contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>cpan@ali.asE<gt>

=head1 SEE ALSO

L<http://ali.as/>, L<YAML>, L<YAML::Syck>, L<Config::Tiny>, L<CSS::Tiny>

=head1 COPYRIGHT

Copyright 2006 Adam Kennedy. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
