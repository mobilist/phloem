=head1 NAME

Phloem::Manual

=head1 DESCRIPTION

The Phloem manual.

=head1 SYNOPSIS

This is just a manual, and does not contain any code. To read the manual, do

  perldoc Phloem::Manual

or

  pod2text lib/Phloem/Manual.pm

=head1 INTRODUCTION

Phloem is a free, open-source Content Delivery Network (CDN) application,
written in Perl.

The aim is for the application to be lightweight and easy to configure. A
secondary aim is for the dependence on non-core Perl modules to be minimal.

=head1 DEPENDENCIES

Phloem currently depends on the following non-core Perl modules.

=over 8

=item XML::Simple

This is used to parse the node definition file, which currently uses an XML
format.

=item App::Prove

As of Perl 5.10.1, this is actually a core module. If you've got an older
Perl, then you'll have to install it using cpan. Sorry about that.

=back

These modules are available from CPAN.

Phloem also requires that C<rsync(1)> and C<ssh(1)> (client and server) be
installed.

A full listing of module dependencies may be generated by running

  ./script/find_dependencies.pl --filter

in the distribution base directory.

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

=head1 CONFIGURATION

=head2 Initial network configuration

It is assumed that you have already configured a basic network of hosts on
which you wish to deploy a Phloem CDN. This will include tasks such as
configuring host names, assigning IP addresses, installing C<rsync(1)> and
C<ssh(1)>, choosing or adding a user account for Phloem to use, generating
RSA keys for C<ssh(1)>, creating directories for content etc.

One important preliminary task is to choose a port number for the registry
server which will be run on the Phloem "root" node. This port must be
accessible as a service port from all other hosts in the Phloem network, and
so any firewall(s) on the "root" host must be configured appropriately.

With the network configuration complete, the main task is to configure Phloem
on each host in the network. This is achieved by editing a single
configuration file (in an XML format for each host.

=head2 Root node configuration

NOT YET WRITTEN!

=head2 Leaf node configuration

NOT YET WRITTEN!

=head2 File/directory paths

A number of file/directory paths must be specified in the the node
configuration XML file. In each case, if an absolute path is not specified,
then the path will be assumed to be relative to the directory from which the
Phloem process is run.

To avoid confusion, therefore, it is best to specify absolute paths.

=head1 OVERVIEW

A basic conceptual overview of Phloem follows.

=head2 PURPOSE

Phloem can serve many purposes. It should be suitable for almost any
application in which content is to be delivered automatically around a
network, from designated directories on each participating host.

Phloem can be configured as a "classical" CDN, in which content flows
automatically from the root node out to the leaves. Content can also be
flowed in the opposite direction; this might be useful for auditing etc.

Another application would be to allow a pair of hosts to share content
automatically between nominated directories --- a "drop box" style file
transfer system.

=head2 NETWORK

=over 8

=item *

The network is a hierarchical arrangement of nodes, precisely one of which
is designated as the "root" node.

=item *

The network topology is tree-like, having no closed loops: a directed
acyclic graph, in other words.

=item *

There are two "routes" through the network:

=over 8

=item "root2leaf"

This is the route flowing from the root node in the direction of the leaf
nodes.

=item "leaf2root"

This is the route flowing from the leaf nodes in the direction of the root
node.

=back

=item *

Each node has a set of "roles", which is a subset of the following set.

  {publisher(root2leaf), publisher(leaf2root),
   subscriber(root2leaf), subscriber(leaf2root)}

=item *

Each node is manually assigned a unique identifier on the network.

=back

=head2 ROLES

=over 8

=item *

Each publisher role nominates a base directory from which content will be
delivered.

N.B. A given node may have 0, 1 or 2 such "outgoing" directories, depending
     on the precise details of the node configuration.

=item *

Each subscriber role nominates a base directry into which content will be
retrieved.

N.B. A given node may have 0, 1 or 2 such "incoming" directories, depending
     on the precise details of the node configuration.

=item *

For a given node having both publish and subscribe roles for a given route,
the "incoming" and "outgoing" base directories may be the same.

=item *

Each publisher node is responsible for populating its own "outgoing"
directory/directories. Note, however, that this does not prevent the node from
nominating a single directory as both "incoming" and "outgoing" on a given
route; in this manner, the node acquires a special role which will be
referred to as that of a "portal" for the affected route.

It is worth emphasising that this is a critical difference from certain
existing system, in which the publish/subscribe mechanism is [ab]used to
populate the root2leaf "outgoing" directory of the top-level node. Phloem is
a pure Phloem system --- it makes no claim to content generation and/or
management.

=item *

Each publisher node has a mechanism for "advertising" its services to
subscribers on the relevant route through the network.

In practice, this mechanism amounts to a "registration" of the publisher
node with the "root" node.

=item *

Each subscriber node has a mechanism for "querying" the network for
publishers on the relevant route.

In practice, this mechanism amounts to a "querying" of a "registry" provided
by the "root" node.

=item *

Each subscriber may define a "filter" to define "preferred" publisher node(s)
from which to retreive its content on the relevant route.

=back

=head2 TRANSPORT

Phloem relies on C<rsync(1)> for its content transport duties. This greatly
alleviates the burdon on the system, delegating all concerns of
synchronisation, compression, authentication, etc.

=head2 LIGHTWEIGHT?

Is the system really lightweight, as intended? Let's examine the proces counts
for a running (single node) system.

Note that each subscriber will run an C<rsync(1)> sub-process from time to
time, in order to transfer data. So the actual process count may be one
higher than indicated below.

=head3 Root node

=over 8

=item Driver (root node)

=item Registry server

This is run as a thread inside the driver process.

=item Node advertiser (root node)

This is run as a thread inside the driver process. In any event, this shuts
down after the first successful node registration.

=item Subscribers (root node)

Subscribers are run as threads inside the driver process.

=back

Total: 1 process, 2--4 threads.

=head3 Non-root node

=over 8

=item Driver (non-root node)

=item Node advertiser (non-root node)

This is run as a thread inside the driver process.

=item Subscribers (non-root node)

Subscribers are run as threads inside the driver process.

=back

Total: 1 process, 2--4 threads (depending on the number of subscriber roles).

=head3 Summary

This is about as lightweight as it could be. (Well, it would be possible to
make it lighter, by re-writing in C/C++; but that would create portability
issues.)

Should the threading prove to have portability issues, there is an
alternative: the main driver process could be re-written to enter a main
loop, running the node advertiser and subscriber chores repeatedly in series.

Also, it might turn out that the registry server needs to be run as a
separate process; it depends whether its workload justifies the overhead.

=head1 TODO

=over 8

=item *

Continue to work on this manual.

=item *

Expand unit test coverage.

=item *

Continue integration testing, and fix any bugs that are found.

=item *

Work out how to exclude *.log files from the Module::Build build process, so
that they do not find their way into the distribution.

=item *

See if the ugly layering of the Debug and Logger modules between Xylem and
Phloem can be done away with. This adds unnecessarily to the complexity of
the code.

=item *

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
