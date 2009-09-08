=head1 NAME

Xylem::Logger

=head1 DESCRIPTION

Logging utilities for Xylem.

=head1 SYNOPSIS

  package MyLogger;
  use base qw(Xylem::Logger);
  sub _do_initialise { Xylem::Logger::path('eggs.log'); };
  package main;
  MyLogger->initialise();
  MyLogger->clear();
  MyLogger->append('Hello teh world!');

=head1 METHODS

=over 8

=cut

package Xylem::Logger;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Xylem::TimeStamp;
use Xylem::Utils::File;

# "Private" storage for the log file path.
our $_LOG_FILE;

# A "private" flag that goes up when the logging subsystem is initialised.
our $_INITIALISED;

#------------------------------------------------------------------------------

=item initialise

Initialise the logging subsystem.

N.B. This is a class method.

=cut

sub initialise
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  die "The logging subsystem has already been initialised." if $_INITIALISED;

  # Perform the (subclass-specific) initialisation.
  $class->_do_initialise();

  # Put up the "initialised" flag.
  $_INITIALISED = 1;
}

#------------------------------------------------------------------------------
sub _do_initialise
# Initialise the logging subsystem --- "protected" method.
#
# Subclasses must provide an implementation for this pure virtual method.
#
# N.B. This is a class method.
{
  die "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

#------------------------------------------------------------------------------

=item path

Get/set the log file path.

=cut

sub path
{
  my $path = shift;

  $_LOG_FILE = $path if defined($path);

  return $_LOG_FILE;
}

#------------------------------------------------------------------------------

=item append

Append the specified message to the log file.

N.B. This is a class method.

=cut

sub append
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Get the input: a message to log.
  my $message = shift or die "No message specified.";
  chomp($message);

  die "The logging subsystem has not yet been initialised."
    unless $_INITIALISED;

  my $log_file = path() or die "No log file path has been set.";

  # Generate a time-stamp.
  my $ts = Xylem::TimeStamp::create();
 
  # Assemble the message: prefix it with the time-stamp.
  $message = "$ts --- $message\n";

  # Print the message to the console too.
  #
  # N.B. We need to use standard error in case we are called from a CGI script.
  print STDERR $message;

  Xylem::Utils::File::append_line($message, $log_file);
}

#------------------------------------------------------------------------------

=item clear

Clear the log file.

N.B. This is a class method.

=cut

sub clear
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  die "The logging subsystem has not yet been initialised."
    unless $_INITIALISED;

  my $log_file = path() or die "No log file path has been set.";

  Xylem::Utils::File::clear($log_file);
}

1;

=back

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Xylem.

   Xylem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Xylem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

=cut
