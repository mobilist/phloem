#!/usr/bin/perl -w
#
#D Unit test script.

# Copyright (C) 2009 Simon Dawson
#
# This file is part of Phloem.
#
#    Phloem is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Phloem is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use diagnostics;

use Test::More tests => 26; # qw(no_plan);

use Phloem::Role::Publish;
use Phloem::Role::Subscribe;
use Phloem::Root;
use Phloem::Rsync;

BEGIN { use_ok('Phloem::Node'); }

my $root;
ok(my $rsync = Phloem::Rsync->new('user' => 'A man'),
   'Creating rsync object.');
my @roles;
my %object_data = ('id'                   => 'egg',
                   'group'                => 'ova',
                   'is_root'              => 1,
                   'host'                 => '0.0.0.0',
                   'register_frequency_s' => 30,
                   'description'          => 'This is the egg.',
                   'root'                 => $root,
                   'rsync'                => $rsync,
                   'roles'                => \@roles);

ok(my $node = Phloem::Node->new(%object_data), 'Creating node object.');

is_deeply($node, \%object_data, 'Internal object data.');
ok($node->id() eq $object_data{'id'}, 'Accessor for id.');
ok($node->group() eq $object_data{'group'}, 'Accessor for group.');
ok($node->is_root() eq $object_data{'is_root'}, 'Accessor for is_root.');
ok($node->host() eq $object_data{'host'}, 'Accessor for host.');
ok($node->register_frequency_s() == $object_data{'register_frequency_s'},
   'Accessor for register frequency in seconds.');
ok($node->description() eq $object_data{'description'},
   'Accessor for description.');
ok(!defined($node->root()), 'Accessor for root.');
ok(my $rsync2 = $node->rsync(), 'Accessor for rsync.');
is_deeply($rsync2, $rsync, 'Rsync objects should match.');
ok($node->roles() == 0, 'Accessor for roles.');

ok(!$node->is_publisher(), 'Node does not publish.');

ok(my $role = Phloem::Role::Publish->new('route'       => 'leaf2root',
                                         'directory'   => 'some/path',
                                         'description' => 'A dummy role.'),
   'Creating publish role object.');

ok($node->add_role($role), 'Adding role to node.');
ok(@roles == 1, 'Number of roles in node.');
ok($node->is_publisher(), 'Node publishes.');
ok(!$node->is_portal($role->route()), 'Node is not portal for route.');

ok(!$node->subscribe_roles(), 'Should be no subscribe roles.');

ok(my $role2 =
   Phloem::Role::Subscribe->new('route'       => $role->route(),
                                'directory'   => $role->directory(),
                                'description' => 'Another dummy role.'),
   'Creating subscribe role object.');

ok($node->add_role($role2), 'Adding role to node.');
ok(@roles == 2, 'Number of roles in node.');
ok($node->subscribe_roles() == 1, 'Should be one subscribe role.');
ok($node->is_portal($role->route()), 'Node is portal for route.');
