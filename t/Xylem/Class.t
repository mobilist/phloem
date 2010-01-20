#!/usr/bin/perl -w
#
# Unit test script for Xylem::Class.

# Copyright (C) 2009-2010 Simon Dawson
#
# This file is part of Xylem.
#
#    Xylem is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Xylem is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use diagnostics;

use Test::More tests => 51; # qw(no_plan);

BEGIN { use_ok('Xylem::Class'); }

# Define some test classes.
use_ok('Dog');
use_ok('Cat');

package Dummy;
  use Xylem::Class ('fields' => {'scalar' => '$',
                                 'array'  => '@',
                                 'hash'   => '%',
                                 'dog'    => 'Dog'});
    package main;

ok(my $dog = Dog->new('Fido'), 'Creating Dog object.');
ok(my $dummy = Dummy->new(), 'Creating Dummy object.');
ok($dummy->isa('Dummy'), 'Should be a Dummy.');
ok(!$dummy->isa('Xylem::Class'), 'Should not be a subclass of Xylem::Class.');
ok(!$dummy->dog(), 'Should be no dog.');
ok($dummy->dog($dog), 'Setting dog.');
ok(my $dog2 = $dummy->dog(), 'Retrieving dog.');
is_deeply($dog2, $dog, 'Objects should be identical.');

# Test a different class hierarchy.
package Donkey;
  use Xylem::Class ('fields' => {'dog' => 'Dog', 'cat' => 'Cat'});
    package main;
ok(my $cat = Cat->new('Oscar'), 'Creating Cat object.');
ok(my $donkey = Donkey->new('dog' => $dog, 'cat' => $cat),
   'Creating Donkey object.');
ok($donkey->isa('Donkey'), 'Should be a Donkey.');
ok(!$donkey->isa('Xylem::Class'), 'Should not be a subclass of Xylem::Class.');
ok(my $dog3 = $donkey->dog(), 'Retrieving dog.');
ok(my $cat2 = $donkey->cat(), 'Retrieving cat.');
is_deeply($dog3, $dog, 'Objects should be identical.');
is_deeply($cat2, $cat, 'Objects should be identical.');

# Test a deeper class hierarchy.
package Monkey;
  use Xylem::Class ('base'   => [qw(Donkey)],
                    'fields' => {'scalar' => '$'});
    package main;
ok(my $monkey = Monkey->new('dog' => $dog, 'scalar' => 34),
   'Creating Monkey object.');
ok($monkey->isa('Monkey'), 'Should be a Monkey.');
ok(!$monkey->isa('Xylem::Class'), 'Should not be a subclass of Xylem::Class.');
ok($monkey->isa('Donkey'), 'Should be a subclass of Donkey.');
ok(my $scalar = $monkey->scalar(), 'Accessor for scalar field.');
is($scalar, 34, 'Value for scalar field.');
ok($monkey->scalar(35), 'Mutator for scalar field.');
is($monkey->scalar(), 35, 'New value for scalar field.');
ok(my $dog4 = $monkey->dog(), 'Retrieving dog.');
is_deeply($dog4, $dog, 'Objects should be identical.');
ok($monkey->cat($cat), 'Mutator for cat.');
ok(my $cat3 = $monkey->cat(), 'Retrieving cat.');
is_deeply($cat3, $cat, 'Objects should be identical.');

# Test multiple inheritance.
package Thing;
  use Xylem::Class ('base'  => [qw(Monkey Donkey)],
                    'fields' => {'array' => '@', 'hash'  => '%'});
    package main;
ok(my $thing = Thing->new(), 'Creating Thing object.');
ok($thing->isa('Thing'), 'Should be a Thing.');
ok(!$thing->isa('Xylem::Class'), 'Should not be a subclass of Xylem::Class.');
ok($thing->isa('Monkey'), 'Should be a subclass of Monkey.');
ok($thing->isa('Donkey'), 'Should be a subclass of Donkey too.');

ok(my $felix = Cat->new('Felix'), 'Creating a Cat object.');
ok(my $thing2 = Thing->new('array'  => [qw(hat shoe cheese)],
                           'scalar' => 101,
                           'cat'    => $felix),
   'Creating another Thing object.');
ok($thing2->isa('Thing'), 'Should be a Thing.');
ok(!$thing2->isa('Xylem::Class'), 'Should not be a subclass of Xylem::Class.');
ok($thing2->isa('Monkey'), 'Should be a subclass of Monkey.');
ok($thing2->isa('Donkey'), 'Should be a subclass of Donkey too.');
is($thing2->scalar(), 101, 'Value for scalar field.');
is_deeply($thing2->array(), [qw(hat shoe cheese)], 'Value for array field.');
ok($thing2->array()->[0] = 'hats', 'Use array field as lvalue.');
is_deeply($thing2->array(), [qw(hats shoe cheese)],
          'Check that array field has changed.');
ok(my $cat4 = $thing2->cat(), 'Accessor for cat.');
is_deeply($cat4, $felix, 'Cats should be identical.');

diag('Testing a base class that does not have a constructor or fields.');
use_ok('Mixin');

package Twist;
  use Xylem::Class ('base' => [qw(Mixin)], 'fields' => {});
    package main;

ok(my $twist = Twist->new(), 'Creating Twist object.');
