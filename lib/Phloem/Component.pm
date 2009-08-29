=head1 NAME

Phloem::Component

=head1 SYNOPSIS

  C<use Phloem::Component;>

=head1 METHODS

=over 8

=item new

Constructor.

=item node

Get the node.

=item role

Get the role.

=item run

Run the component.

Spawns a child process, and returns the PID.

=item shut_down

Shut down the component.

If an argument is supplied, it is used as the exit code. Otherwise, the
component exits with a standard "success" exit code (0).

=back

=head1 DESCRIPTION

An abstract base class for Phloem components.

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

package Phloem::Component;

use strict;
use warnings;
use diagnostics;

use Class::Struct 'Phloem::Component' => {'node' => 'Phloem::Node',
                                          'role' => 'Phloem::Role'};

use lib qw(lib);
use Phloem::Logger;
use Phloem::Node;
use Phloem::Role;
use Xylem::Utils::Process;

#------------------------------------------------------------------------------
sub run
# Run the component.
#
# Spawns a child process, and returns the PID.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Spawn a new child process to run the component.
  my $child_pid = Xylem::Utils::Process::spawn_child('NODAEMON' => 1);
  return $child_pid if $child_pid;

  # (We're in the child process now.)
  $self->_do_run();
}

#------------------------------------------------------------------------------
sub shut_down
# Shut down the component.
#
# If an argument is supplied, it is used as the exit code. Otherwise, the
# component exits with a standard "success" exit code (0).
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $exit_code = shift // 0;

  Phloem::Logger::append(
    "Component shutting down with exit code $exit_code.");

  exit($exit_code);
}

#------------------------------------------------------------------------------
sub _do_run
# Run the component --- "protected" method.
{
  die "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

1;
