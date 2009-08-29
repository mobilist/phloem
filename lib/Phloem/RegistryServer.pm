=head1 NAME

Phloem::RegistryServer

=head1 SYNOPSIS

  C<use Phloem::RegistryServer;>

=head1 DESCRIPTION

Registry server for Phloem.

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Phloem.

   Phloem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Phloem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

=cut

package Phloem::RegistryServer;

use strict;
use warnings;
use diagnostics;

use base 'Xylem::Server';

use lib qw(lib);
use Phloem::Constants;
use Phloem::Registry;

#------------------------------------------------------------------------------
sub process_request
# Process the request on the specified client socket --- "protected" method.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $client_sock = shift or die "No client socket specified.";
  die "Expected a TCP/IP socket." unless $client_sock->isa('IO::Socket::INET');

  # Use time-outs to prevent denial-of-service attacks while reading.
  my $input = '';
  eval {

    local $SIG{'ALRM'} = sub { die "Timed out."; };
    my $timeout = $Phloem::Constants::REGISTRY_SERVER_TIMEOUT_S;

    my $previous_alarm = alarm($timeout);
    while (<$client_sock>) {
      $_ =~ s/\r?\n$//o;
      $input .= $_;
      alarm($timeout);
    }
    alarm($previous_alarm);

  };

  if ($@ =~ /Timed out\./o) {
    print $client_sock "ERROR: Timed out.\r\n";
    return;
  }

  # Load the registry.
  my $registry = Phloem::Registry->load();

  # See what we got.
  if ($input =~ /^\s*GET\s*$/o) {
    # The client wants details of the registry.
    print $client_sock $registry->data_dump(), "\r\n";
  } else {
    # The client is sending us details of a node.
    my $node = Phloem::Node->data_load($input)
      or die "Failed to recreate node object.";

    # Update the registry with the node information.
    $registry->add_node($node);

    # Save the updated registry.
    $registry->save();
  }
}

1;
