=head1 NAME

Xylem::Class

=head1 DESCRIPTION

A base class for Xylem classes.

=head1 SYNOPSIS

  package MyClass;
  use Some::Class;
  use Some::Other::Class;
  use Xylem::Class ('_base'   => [qw(Some::Other::Class)],
                    'name'    => '$',
                    'aliases' => '@',
                    'data'    => '%',
                    'object'  => 'Some::Class');
  package main;

  my $thing = MyClass->new('name' => 'toiletduck');
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

Parameters passed to "use" are a hash table of element names and types, in
the style of Class::Struct.

In addition to the usual Class::Struct parameters, base class information
may be specified using the '_base' key. The value may be either a string (for
specifying a single base class) or an array reference (for specifying multiple
base classes).

N.B. This is a class method.

=cut

sub import
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Get the name of the calling class.
  my $caller = caller();

  # Our input takes the form of a hash table.
  my %args = @_;

  # Did we get base class information?
  my @bases;
  if (exists($args{'_base'})) {
    my $_base = $args{'_base'} or croak "No base class(es) specified.";
    if (ref($_base)) {
      # We must have been given an array reference.
      croak "Expected an array reference." unless (ref($_base) eq 'ARRAY');
      @bases = @$_base;
    } else {
      # Just assume that we got a class name.
      push(@bases, $_base);
    }
    delete($args{'_base'});
  }

  # Sort out the base class information.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    # Add this class as a base of the calling class.
    #
    # N.B. We do this before we add any explicitly-named base classes, because
    #      this is the lowest-level base class.
    push(@{$caller . '::ISA'}, __PACKAGE__);

    # Add the specified base classes as bases of the calling class.
    foreach my $base (@bases) {
      push(@{$caller . '::ISA'}, $base);
    }
  }

  # Generate the "guts" of an object hash reference.
  my $self = {};
  foreach my $key (keys(%args)) {
    # Check the element type.
    my $value = $args{$key}
      or croak "No element type specified for element '$key'.";
    croak "'$value' is not a valid element type."
      unless ($value =~ /^\*?(?:\$|\@|\%|[A-Z][\w:]*)$/o);

    # Initialise the element value.
    if ($value =~ /^\*?\@$/o) {
      $self->{$key} = [];
    } elsif ($value =~ /^\*?\%$/o) {
      $self->{$key} = {};
    } else {
      $self->{$key} = undef;
    }
  }

  # Define a class method in the calling package, to retrieve the element
  # type information.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    *{$caller . '::_get_element_types'} = sub {
      my $class = shift or croak "No class name specified.";
      croak "Expected an ordinary scalar." if ref($class);
      croak "Incorrect class name." unless $class->isa(__PACKAGE__);

      return %args;
    };
  }

  # Generate a constructor in the calling package.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    croak "Method 'new' already exists in package $class."
      if defined(*{$caller . '::new'});
    *{$caller . '::new'} = sub {
      my $class = shift or croak "No class name specified.";
      croak "Expected an ordinary scalar." if ref($class);
      croak "Incorrect class name ($class)." unless $class->isa("$caller");

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
        my $current_base_part = eval { $base->new(); } || {};
        croak "Failed to contruct $base part: $@" if $@;
        $self_base = {%$current_base_part, %$self_base};
      }

      # Assemble the object from the "guts", plus base class part, plus
      # arguments.
      my %args = @_;
      $self = {%$self, %$self_base, %args};
      return bless($self, $class);
    };
  }
}

#------------------------------------------------------------------------------
sub AUTOLOAD
# Automatically generate accessor/mutator methods.
#
# This provides a definition for a missing subroutine, by assigning a closure
# to the AUTOLOAD typeglob. The subroutine is then executed using the special
# form of goto that can erase the stack frame of the AUTOLOAD routine.
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  our $AUTOLOAD =~ /([^:]+)$/o;
  my $element = $1 or croak "Failed to determine element name.";

  # Get out right now if we are being called for a destructor.
  return if ($element eq 'DESTROY');

  # Look for the element in the object hash.
  croak "Element '$element' not recognised." unless exists($self->{$element});

  # Get element type information.
  my $element_type;
  {
    my %element_types = ref($self)->_get_element_types()
      or croak "Failed to get element type information.";
    $element_type = $element_types{$element}
      or croak "Failed to get type information for element '$element'.";
  }

  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    # Does an accessor/mutator method exist already? If so, then we don't
    # want to redefine it.
    unless (defined(*$AUTOLOAD{'CODE'})) {

      # Define an accessor/mutator method.
      #
      # N.B. We have to do a bit of mucking about with the argument order.
      #      See the comments inside _generic_accessor_mutator() for more
      #      details. The important point here is that the call is pre-bound
      #      in the closure to specific element name and type details. That
      #      is important because those are the arguments that will NOT be
      #      passed in to the autoload method when it is called in the future.
      *{$AUTOLOAD} =
        sub { return _generic_accessor_mutator($element, $element_type, @_); };
    }

    # Restart the new routine.
    #
    # N.B. Remember to put the invoking object back onto the front of the
    # argument list.
    unshift(@_, $self);
    goto &$AUTOLOAD;
  }
}

#------------------------------------------------------------------------------
sub _generic_accessor_mutator
# Generic accessor/mutator method.
{
  # N.B. Note the rather strange argument order here. Specifically, the
  #      invoking object reference comes after the element name and type
  #      details.
  #
  #      This is done because the element name and type are bound to a call
  #      to this method in an autoload closure. (See the AUTOLOAD method for
  #      further details.) The upshot of this is that when the generated
  #      autoload method is called, the "real" arguments will be passed in
  #      _after_ the element name and type.

  my $element = shift or croak "No element specified.";
  croak "Expected an ordinary scalar." if ref($element);

  my $element_type = shift or croak "No element type specified.";
  croak "Expected an ordinary scalar." if ref($element_type);

  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Look for the element in the object hash.
  croak "Element '$element' not recognised." unless exists($self->{$element});

  my $wantref = ($element_type =~ /^\*/o);
  if ($element_type =~ /^\*?\$$/o) {
    # Scalar.
    $self->{$element} = shift if @_;

    return $wantref ? \{$self->{$element}} : $self->{$element};
  } elsif ($element_type =~ /^\*?\@$/o) {
    # Array.
    if (@_ == 0) {
      # Always return the array reference.
      return $self->{$element};
    } elsif (@_ == 1) {
      if (ref($_[0])) {
        # Assign the entire array from the specified reference.
        my $value = shift;
        croak "Expected an array reference." unless (ref($value) eq 'ARRAY');
        $self->{$element} = $value;
        return $self;
      } else {
        # Return an array slot [reference] for the specified index.
        my $index = shift;
        croak "Expected an array index." unless ($index =~ /^\d+$/o);
        return $wantref ?
          \{$self->{$element}->[$index]} : $self->{$element}->[$index];
      }
    } elsif (@_ == 2) {
      # Assign to an array slot.
      my $index = shift;
      my $value = shift;
      croak "Expected an array index." unless ($index =~ /^\d+$/o);
      $self->{$element}->[$index] = $value;
      return $wantref ?
        \{$self->{$element}->[$index]} : $self->{$element}->[$index];
    } else {
      croak "Expected no more than two arguments.";
    }
  } elsif ($element_type =~ /^\*?\%$/o) {
    # Hash.
    if (@_ == 0) {
      # Always return the hash reference.
      return $self->{$element};
    } elsif (@_ == 1) {
      if (ref($_[0])) {
        # Assign the entire hash from the specified reference.
        my $value = shift;
        croak "Expected a hash reference." unless (ref($value) eq 'HASH');
        $self->{$element} = $value;
        return $self;
      } else {
        # Return a hash slot [reference] for the specified key.
        my $key = shift;
        return $wantref ?
          \{$self->{$element}->{$key}} : $self->{$element}->{$key};
      }
    } elsif (@_ == 2) {
      # Assign to a hash slot.
      my $key = shift;
      my $value = shift;
      $self->{$element}->{$key} = $value;
      return $wantref ?
        \{$self->{$element}->{$key}} : $self->{$element}->{$key};
    } else {
      croak "Expected no more than two arguments.";
    }
  } else {
    # Object.
    croak "Unexpected element type designation."
      unless ($element_type =~ /^\*?([A-Z][\w:]*)$/o);
    my $element_class = $1;
    if (@_ == 1) {
      my $value = shift;
      croak "Expected a reference." unless ref($value);
      croak "Unexpected object class." unless $value->isa($element_class);
      $self->{$element} = $value;
    } elsif (@_) {
      croak "Expected no more than a single argument.";
    }
    return $wantref ? \{$self->{$element}} : $self->{$element};
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
