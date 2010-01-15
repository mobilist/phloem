=head1 NAME

Xylem::Class

=head1 DESCRIPTION

A base class for Xylem classes.

=head1 SYNOPSIS

  package MyClass;
  use Some::Class;
  use Some::Other::Class;
  use Xylem::Class ('package' => 'MyClass',
                    'bases'   => [qw(Some::Other::Class)],
                    'fields'  => {'name'    => '$',
                                  'aliases' => '@',
                                  'data'    => '%',
                                  'object'  => 'Some::Class'});
  package main;

  my $thing = MyClass->new('package' => 'toiletduck');
  my $dummy = Some::Class->new(...);
  $thing->object($dummy);

=head1 METHODS

=over 8

=cut

package Xylem::Class;

use strict;
use warnings;
use diagnostics;

use Carp;

#------------------------------------------------------------------------------

=item new

Constructor.

=cut

sub new
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  return bless({}, $class);
}

#------------------------------------------------------------------------------

=item import

Called automatically when this module is "use"ed; you should never need to
call this explicitly.

Parameters passed to "use" are a hash table. Under the 'package' hash key is
the name of the target class package.

Under the 'fields' hash key is a hash reference of field names and types,
in the style of Class::Struct.

Base class information may optionally be specified using the 'bases' hash key.
The value may be either a string (for specifying a single base class) or an
array reference (for specifying multiple base classes).

N.B. This is a class method.

=cut

sub import
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Our input takes the form of a hash table.
  my %use_args = @_;
  return 1 unless keys(%use_args);
  my $target_package = $use_args{'package'}
    or croak "No target class package specified.";
  croak "Expected an ordinary scalar." if ref($target_package);
  my $fields = $use_args{'fields'} || {}; # N.B. There might not be any fields.
  croak "EXpected a hash reference." unless (ref($fields) eq 'HASH');

  # We don't want to pollute the top-level namespace.
  return 1 if ($target_package eq 'main');

  # Have we already worked on the target package.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    return 1 if defined(*{$target_package . '::new'});
  }

  # Did we get base class information?
  my @bases;
  if (exists($use_args{'bases'})) {
    my $_base = $use_args{'bases'} or croak "No base class(es) specified.";
    if (ref($_base)) {
      # We must have been given an array reference.
      croak "Expected an array reference." unless (ref($_base) eq 'ARRAY');
      @bases = @$_base;
    } else {
      # Just assume that we got a class name.
      push(@bases, $_base);
    }
  }

  # Sort out the base class information.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    # Add this class as a base of the target class.
    #
    # N.B. We do this before we add any explicitly-named base classes, because
    #      this is the lowest-level base class.
    unless (defined(*{$target_package . '::ISA'})) {
      # Create an empty ISA array, if necessary.
      *{$target_package . '::ISA'} = [];
    }
    my $this_package = __PACKAGE__;
    push(@{$target_package . '::ISA'}, $this_package);

    # Add the specified base classes as bases of the target class.
    push(@{$target_package . '::ISA'}, @bases);
  }

  # Generate the "guts" of an object hash reference, and accessor/mutator
  # methods.
  my $self = {};
  foreach my $field_name (keys(%$fields)) {
    # Check the field type.
    my $field_type = $fields->{$field_name}
      or croak "No field type specified for field '$field_name'.";
    croak "'$field_type' is not a valid field type."
      unless ($field_type =~ /^\*?(?:\$|\@|\%|[A-Z][\w:]*)$/o);

    # Initialise the field value.
    if ($field_type =~ /^\*?\@$/o) {
      $self->{$field_name} = [];
    } elsif ($field_type =~ /^\*?\%$/o) {
      $self->{$field_name} = {};
    } else {
      $self->{$field_name} = undef;
    }

    # Generate an accessor/mutator method for the field.
    {
      # N.B. We're going to be using symbolic references for a while.
      no strict 'refs';

      # Does an accessor/mutator method exist already? If so, then we don't
      # want to redefine it.
      next if defined(*{$target_package . '::' . $field_name});
      {

        # Define an accessor/mutator method.
        #
        # N.B. We have to do a bit of mucking about with the argument order.
        #      See the comments inside _generic_accessor_mutator() for more
        #      details. The important point here is that the call is pre-bound
        #      in the closure to specific field name and type details. That
        #      is important because those are the arguments that will NOT be
        #      passed in to the generated method when it is called in the
        #      future.
        *{$target_package . '::' . $field_name} = sub {
          return _generic_accessor_mutator($field_name, $field_type, @_);
        };
      }
    }
  }

  # Generate a constructor in the target package.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    croak "Method 'new' already exists in package $class."
      if defined(*{$target_package . '::new'});
    *{$target_package . '::new'} = sub {
      my $class = shift or croak "No class name specified.";
      croak "Expected an ordinary scalar." if ref($class);
      croak "Incorrect class name ($class)."
        unless $class->isa("$target_package");

      # Construct the base class parts, if the base classes define
      # constructors.
      #
      # N.B. This used to be done using...
      #
      #        my $self_base = eval { $class->SUPER::new(); } || {};
      #
      #      ... but clearly that wouldn't work for multiple bases. The problem
      #      now is that we might miss superclasses that weren't declared using
      #      the '_base' constructor key. I think we'll just have to live with
      #      that.
      my $self_base = {};
      foreach my $base (@bases) {
        # N.B. It is not an error for a base class to not define a constructor.
        #
        #      For example, a base class might be a "mixin", in which case it
        #      will typically not define a constructor.
        my $current_base_part = eval { $base->new(); } or next;
        $self_base = {%$current_base_part, %$self_base};
      }

      # Assemble the object from the "guts", plus base class part, plus
      # arguments.
      my %args = @_;
      $self = {%$self, %$self_base, %args};
      return bless($self, $class);
    };
  }

  return 1;
}

#------------------------------------------------------------------------------
sub _generic_accessor_mutator
# Generic accessor/mutator method.
{
  # N.B. Note the rather strange argument order here. Specifically, the
  #      invoking object reference comes after the field name and type
  #      details.
  #
  #      This is done because the field name and type are bound to a call
  #      to this method in a closure. (See the method generation code in
  #      import() for further details.) The upshot of this is that when the
  #      generated method is called, the "real" arguments will be passed in
  #      _after_ the field name and type.

  my $field_name = shift or croak "No field name specified.";
  croak "Expected an ordinary scalar." if ref($field_name);

  my $field_type = shift or croak "No field type specified.";
  croak "Expected an ordinary scalar." if ref($field_type);

  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Look for the field in the object hash.
  croak "Field '$field_name' not recognised."
    unless exists($self->{$field_name});

  my $wantref = ($field_type =~ /^\*/o);
  if ($field_type =~ /^\*?(?:\@|\%)$/o) {
    # Array/hash.
    my $field_is_array = ($field_type =~ /^\*?\@$/o);
    if (@_ == 0) {
      # Always return the field.
      return $self->{$field_name};
    } elsif (@_ > 2) {
      # Too many arguments.
      croak "Expected no more than two arguments.";
    } elsif (@_ == 1 && ref($_[0])) {
      # Assign the entire field from the specified reference.
      my $value = shift;
      if ($field_is_array) {
        croak "Expected an array reference." unless (ref($value) eq 'ARRAY');
      } else {
        croak "Expected a hash reference." unless (ref($value) eq 'HASH');
      }
      $self->{$field_name} = $value;
      return $self;
    } else {
      # Exactly one non-reference argument, or exactly two arguments.
      if ($field_is_array) {
        # Array.
        my $index = shift;
        croak "Expected an array index." unless ($index =~ /^\d+$/o);
        if (@_) {
          # Assign to an array slot.
          my $value = shift;
          $self->{$field_name}->[$index] = $value;
        }
        # Return an array slot [reference] for the specified index.
        return $wantref ?
          \{$self->{$field_name}->[$index]} : $self->{$field_name}->[$index];
      } else {
        # Hash.
        my $key = shift;
        if (@_) {
          # Assign to a hash slot.
          my $value = shift;
          $self->{$field_name}->{$key} = $value;
        }
        # Return a hash slot [reference] for the specified key.
        return $wantref ?
          \{$self->{$field_name}->{$key}} : $self->{$field_name}->{$key};
      }
    }
  } else {
    # Scalar/object.
    if (@_) {
      my $value = shift;

      unless ($field_type =~ /^\*?\$$/o) {
        # Object.
        croak "Expected a reference." unless ref($value);

        croak "Unexpected field type designation."
          unless ($field_type =~ /^\*?([A-Z][\w:]*)$/o);
        my $field_class = $1;
        croak "Unexpected object class." unless $value->isa($field_class);
      }

      $self->{$field_name} = $value;

      croak "Expected no more than a single argument." if @_;
    }

    return $wantref ? \{$self->{$field_name}} : $self->{$field_name};
  }

  # If we get here, then something's gone wrong.
  croak "Unexpected problem.";
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
