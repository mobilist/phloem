#!/usr/bin/perl -w

=head1 NAME

new_script.pl

=head1 DESCRIPTION

Create a new Phloem script.

=head1 SYNOPSIS

new_script.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-f, --force>

Force the overwriting of an existing file.

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

use strict;
use warnings;
use diagnostics;

use File::Spec;

use lib qw(lib);
use Xylem::Utils::Code;

use constant SCRIPT_DEST_DIR => 'script';

#==============================================================================
# Start of main program.
{
  my ($opt_f);
  Xylem::Utils::Code::process_command_line('f|force' => \$opt_f);

  # Get the script name, and fix it up.
  my $script_name = shift or pod2usage(-verbose => 0);
  $script_name =~ s/\.pl$//io;
  $script_name .= '.pl';

  # Assemble the script file path.
  my $script_file = File::Spec->catfile(SCRIPT_DEST_DIR, $script_name);

  # Use a hard-coded package name for now. We can't infer this from anything.
  my $package_name = 'Phloem';

  # More metadata.
  my $author = 'Simon Dawson';
  my $author_email = 'spdawson@gmail.com';

  # Write the script file.
  Xylem::Utils::Code::write_script_file('script_name'  => $script_name,
                                        'package_name' => $package_name,
                                        'script_file'  => $script_file,
                                        'author'       => $author,
                                        'author_email' => $author_email,
                                        'force'        => $opt_f);
}
# End of main program.
