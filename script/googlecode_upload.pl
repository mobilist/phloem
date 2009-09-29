#!/usr/bin/perl -w

=head1 NAME

googlecode_upload.pl

=head1 DESCRIPTION

Utility script to upload a specified file to a Google code repository.

=head1 SYNOPSIS

googlecode_upload.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-u, --user>

Specify the user name. This argument is mandatory.

=item B<-p, --password>

Specify the password. This argument is mandatory.

=item B<-d, --description>

Specify the description. This argument is mandatory.

=item B<-r, --project>

Specify the project name. This argument is mandatory.

=item B<-f, --file>

Specify the file path to be uploaded. This argument is mandatory.

=item B<-t, --label>

Specify a label. This argument is optional, and may be used multiple times.

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

use LWP::UserAgent;

use lib qw(lib);
use Xylem::Utils::Code;

#==============================================================================
# Start of main program.
{
  my ($opt_u, $opt_p, $opt_d, $opt_r, $opt_f, @opt_t);
  Xylem::Utils::Code::process_command_line('u|user=s'        => \$opt_u,
                                           'p|password=s'    => \$opt_p,
                                           'd|description=s' => \$opt_d,
                                           'r|project=s'     => \$opt_r,
                                           'f|file=s'        => \$opt_f,
                                           't|label=s'       => \@opt_t);

  # Only label arguments are optional; everything else is mandatory.
  die "No user name specified." unless $opt_u;
  die "No password specified." unless $opt_p;
  die "No description specified." unless $opt_d;
  die "No project specified." unless $opt_r;
  die "No file specified." unless $opt_f;

  # Prepend the word 'label' to each label.
  @opt_t = map {('label', $_)} @opt_t;

  # Upload the file.
  {
    my $ua = LWP::UserAgent->new();
    my $url = 'https://' . "$opt_u:$opt_p\@$opt_r" . '.googlecode.com/files';
    my $response = $ua->post($url,
                             'Content_Type' => 'form-data',
                             'Content'      => ['summary'  => $opt_d,
                                                'filename' => [$opt_f],
                                                @opt_t]);

    # Report status and exit with an appropriate code.
    if ($response->is_success()) {
      print $response->content(), "\n";
      exit(0);
    } else {
      print STDERR $response->status_line(), "\n";
      exit(1);
    }
  }
}
# End of main program; subroutines follow.
