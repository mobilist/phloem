#!/usr/bin/perl -w
#
#D Logger test script.

use strict;
use warnings;
use diagnostics;

use FileHandle;
use Log::Message::Simple;

use constant LOG_FILE => 'dummy.log';

{
  print "Initialise logging subsystem.\n";
  my $log_fh = FileHandle->new('> ' . LOG_FILE)
    or die "Failed to open log file for writing: $!";
  initialise($log_fh);
  clear();
  append('This should not be seen in the final log.');
  clear();
  append('Hello teh Log!');
}

#------------------------------------------------------------------------------

=item initialise

Initialise the logging subsystem, using the specified logging filehandle.

=cut

sub initialise
{
  my $fh = shift or die "No filehandle specified.";
  die "Expected a FileHandle reference."
    unless ($fh->isa('FileHandle') || ref($fh) eq 'GLOB');

  # Redirect logging output.
  $Log::Message::Simple::MSG_FH   = $fh;
  $Log::Message::Simple::ERROR_FH = $fh;
  $Log::Message::Simple::DEBUG_FH = $fh;

  # Force a stack trace on error.
  $Log::Message::Simple::STACKTRACE_ON_ERROR = 1;
}

#------------------------------------------------------------------------------

=item append

Append the specified message to the specified log file.

=cut

sub append
{
  # Get the input: a message to log.
  my $message = shift or die "No message specified.";
  chomp($message);

  Log::Message::Simple::msg($message, 1);
}

#------------------------------------------------------------------------------

=item clear

Clear the specified log file.

=cut

sub clear
{
  Log::Message::Simple::flush();
}
