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

  # Add this class as a base of the calling class.
  #
  # N.B. We do this before we add any explicitly-named base classes, because
  #      this is the lowest-level base class.
  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    push(@{$caller . '::ISA'}, __PACKAGE__);
  }

  # Our input takes the form of a hash table.
  my %args = @_;

  # Did we get base class information?
  if (exists($args{'_base'})) {
    my @bases;
    {
      my $_base = $args{'_base'};
      croak "No base class(es) specified." unless $_base;
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

    # Add the specified base classes as bases of the calling class.
    {
      # N.B. We're going to be using symbolic references for a while.
      no strict 'refs';

      foreach my $base (@bases) {
        push(@{$caller . '::ISA'}, $base);
      }
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
    $self->{$key} = undef;
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

      # Construct the base class part, if the base class defines a constructor.
      my $self_base = eval { $class->SUPER::new(); } || {};

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
  my $element = $1;

  # Get out right now if we are being called for a destructor.
  return if ($element eq 'DESTROY');

  # Look for the element in the object hash.
  croak "Element '$element' not recognised." unless exists($self->{$element});

  # Get element type information.
  my %element_types = ref($self)->_get_element_types();

  {
    # N.B. We're going to be using symbolic references for a while.
    no strict 'refs';

    # Does an accessor/mutator method exist already? If so, then we don't
    # want to redefine it.
    unless (defined(*$AUTOLOAD{'CODE'})) {

      # Define a subroutine.
      #
      # N.B. Really, the subroutine should behave differently, depending on
      #      the element type.
      carp "NOT YET WRITTEN!";
      *{$AUTOLOAD} = sub {
        my $self = shift or croak "No object reference.";
        croak "Unexpected object class." unless $self->isa(__PACKAGE__);

        $self->{$element} = shift if @_;

        return $self->{$element};
      };
    }

    # Restart the new routine.
    unshift(@_, $self);
    goto &$AUTOLOAD;
  }
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
