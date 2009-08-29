=head1 NAME

Phloem::Constants

=head1 SYNOPSIS

  C<use Phloem::Constants;>

=head1 DESCRIPTION

Constants for Phloem.

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

package Phloem::Constants;

our $LOG_FILE                        = 'phloem.log';
our $CONFIG_FILE                     = 'etc/node.xml';
our $REGISTRY_FILE                   = 'etc/registry.txt';

our $REGISTRY_SERVER_TIMEOUT_S       = 30;

our $SUBSCRIBER_UPDATE_SLEEP_TIME_S  = 10;
our $NODE_REGISTER_SLEEP_TIME_S = 10;


1;
