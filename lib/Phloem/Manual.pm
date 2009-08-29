=head1 NAME

Phloem::Manual

=head1 SYNOPSIS

  C<perldoc Phloem::Manual>

But then, if you're reading this, then you've probably figured that out...

=head1 DESCRIPTION

The Phloem manual.

=head1 INTRODUCTION

Phloem is a free, open-source Content Delivery Network (Phloem) application,
written in Perl.

The aim is for the application to be lightweight and easy to configure. A
secondary aim is for the dependence on non-core Perl modules to be minimal.

=head1 DEPENDENCIES

Phloem currently depends on the following non-core Perl modules.

=over 8

=item XML::Simple

This is used to parse the node definition file, which currently uses an XML
format.

=back

These modules are available from CPAN.

Phloem also requires that rsync and ssh (client and server) be installed.

=head1 INSTALLATION

Phloem uses Module::Build for its installation process.

To install Phloem, do the following.

=over 8

=item 1

perl Build.PL

=item 2

./Build

=item 3

./Build test

=item 4

./Build install

=back

=head1 OVERVIEW

A basic conceptual overview of Phloem follows.

=head2 NETWORK

=over 8

=item

The network is a hierarchical arrangement of nodes, precisely one of which
is designated as the "root" node.

=item

The network topology is tree-like, having no closed loops: a directed
acyclic graph, in other words.

=item

There are two "routes" from the "root" node to a leaf node: "rootward"
and "leafward".

=item

Each node has a set of "roles", which is a subset of the following set.

  {publisher(leafward), publisher(rootward),
   subscriber(leafward), subscriber(rootward)}

=item

Each node is manually assigned a unique identifier on the network.

=back

=head2 ROLES

=over 8

=item

Each publisher role nominates a base directory from which content will be
delivered.

N.B. A given node may have 0, 1 or 2 such "outgoing" directories, depending
     on the precise details of the node configuration.

=item

Each subscriber role nominates a base directry into which content will be
retrieved.

N.B. A given node may have 0, 1 or 2 such "incoming" directories, depending
     on the precise details of the node configuration.

=item

For a given node having both publish and subscribe roles for a given route,
the "incoming" and "outgoing" base directories may be the same.

=item

Each publisher node is responsible for populating its own "outgoing"
directory/directories. Note, however, that this does not prevent the node from
nominating a single directory as both "incoming" and "outgoing" on a given
route; in this manner, the node acquires a special role which will be
referred to as that of a "portal" for the affected route.

It is worth emphasising that this is a critical difference from certain
existing system, in which the publish/subscribe mechanism is [ab]used to
populate the leafward "outgoing" directory of the top-level node. Phloem is
a pure Phloem system --- it makes no claim to content generation and/or
management.

=item

Each publisher node has a mechanism for "advertising" its services to
subscribers on the relevant route through the network.

In practice, this mechanism amounts to a "registration" of the publisher
node with the "root" node.

=item

Each subscriber node has a mechanism for "querying" the network for
publishers on the relevant route.

In practice, this mechanism amounts to a "querying" of a "registry" provided
by the "root" node.

=item

Each subscriber may define a "filter" to define "preferred" publisher node(s)
from which to retreive its content on the relevant route.

=back

=head2 TRANSPORT

Phloem relies on rsync for its content transport duties. This greatly
alleviates the burdon on the system, delegating all concerns of
synchronisation, compression, authentication, etc.

=head1 TODO

=over 8

=item

Finish writing code.

=item

Make more extensive use of Class::Struct, to eliminate "bolier-plate" code.

=item

Expand unit test coverage.

=item

Integration testing.

=item

Use the logger where appropriate.

=item

Add support for custom content update/transport mechanisms (via "plugins").

=item

Write some more detailed module documentation.

=back

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
