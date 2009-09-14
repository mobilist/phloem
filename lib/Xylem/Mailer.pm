=head1 NAME

Xylem::Mailer

=head1 DESCRIPTION

A wrapper around Mail::Sendmail::sendmail, allowing files to be sent as e-mail
attachments.

=head1 SYNOPSIS

  use Xylem::Mailer;
  Xylem::Mailer::sendmail('to'         => 'lemuelg@gmail.com',
                          'from'       => 'samueleggs@gmail.com',
                          'subject'    => 'Your research proposal',
                          'message'    => 'I likes it, I does!',
                          'attachment' => 'some/file.txt')
    or die "Failed to send e-mail.";

=head1 METHODS

=over 8

=cut

package Xylem::Mailer;

use strict;
use warnings;
use diagnostics;

use Carp;
use Cwd qw();
use English;
use File::Basename qw();
use File::Temp;
use Mail::Sendmail qw();
use MIME::QuotedPrint qw();
use MIME::Base64 qw();

use Xylem::Utils::File;

# The maximum size for an attachment file --- larger files will be compressed.
use constant MAX_ATTACHMENT_SIZE_BYTES => 1E7; # 10MB.

#------------------------------------------------------------------------------

=item sendmail

Send an e-mail.

This is essentially a wrapper around the Mail::Sendmail::sendmail method. The
following hash keys are supported: to, from, subject, message, attachment. The
attachment key is an extension to the Mail::Sendmail::sendmail API, and allows
an attachment file path to be specified.

=cut

sub sendmail
{
  my %args = @_;
  my $to = $args{'to'} or croak "No to address(es) specified.";
  my $from = $args{'from'} or croak "No from address specified.";
  my $subject = $args{'subject'} or croak "No subject specified.";
  my $message = $args{'message'} or croak "No message specified.";
  my $attachment = $args{'attachment'}; # Optional argument.

  my $mail_sent_ok;

  # Did we get an attachment file name?
  if ($attachment) {
    $mail_sent_ok = _sendmail_with_attachment(%args);
  } else {

    # Put together the hash of message parameters.
    my %mail = ('to'      => $to,
                'from'    => $from,
                'subject' => $subject,
                'message' => $message);

    # Attempt to send the e-mail.
    $mail_sent_ok = Mail::Sendmail::sendmail(%mail);
  }

  unless ($mail_sent_ok) {
    carp "Failed to send mail: $Mail::Sendmail::error";
    return;
  }

  return 1;
}

#------------------------------------------------------------------------------
sub _sendmail_with_attachment
# Send an e-mail with an attachment.
{
  my %args = @_;
  my $to = $args{'to'} or croak "No to address(es) specified.";
  my $from = $args{'from'} or croak "No from address specified.";
  my $subject = $args{'subject'} or croak "No subject specified.";
  my $message = $args{'message'} or croak "No message specified.";
  my $attachment = $args{'attachment'} or croak "No attachment specified.";

  # Check that we can attach the specified file.
  croak "Cannot find attachment file $attachment." unless (-f $attachment);

  # Attempt to resolve ("follow") symbolic links.
  if (-l $attachment) {
    $attachment = readlink($attachment)
      or croak "Failed to resolve symbolic link: $!";
  }

  # Remove carriage returns from the attachment file.
  Xylem::Utils::File::strip_cr($attachment);

  # We also need a bare filename to use for the attachment.
  my ($attachment_name, undef, undef) = File::Basename::fileparse($attachment);

  # Compress the attachment file, if it is too large.
  my $file_to_attach = $attachment;
  if (-s $attachment > MAX_ATTACHMENT_SIZE_BYTES) {
    $file_to_attach = _compress_file_to_temp($attachment);
    $attachment_name .= '.tar.gz';
  }

  my ($multipart_message, $content_type) =
    _get_multipart_message($message, $file_to_attach, $attachment_name);

  # Put together the hash of message parameters.
  my %mail = ('to'      => $to,
              'from'    => $from,
              'subject' => $subject,
              'message' => $multipart_message);

  $mail{'content-type'} = $content_type;

  # Attempt to send the e-mail.
  my $mail_sent_ok = Mail::Sendmail::sendmail(%mail);

  # Delete the compressed attachment file, if necessary.
  if ($file_to_attach ne $attachment) {
    unlink($file_to_attach)
      or carp "Failed to delete compressed attachment $file_to_attach: $!";
  }

  return $mail_sent_ok;
}

#------------------------------------------------------------------------------
sub _get_multipart_message
# Get a multi-part MIME message, comprising the specified message text and
# attachment file.
{
  my $message = shift or croak "No message specified.";
  my $attachment = shift or croak "No attachment specified.";
  my $attachment_name = shift or croak "No attachment name specified.";

  # Put together a unique (ish) boundary string for the multi-part message.
  my $boundary = "====" . time() . "====";
  my $content_type = "multipart/mixed; boundary=\"$boundary\"";

  # Encode the body text of the message.
  $message = MIME::QuotedPrint::encode_qp($message);

  # Read the file to attach, creating a text representation.
  my $attachment_text = Xylem::Utils::File::read($attachment);
  $attachment_text = MIME::Base64::encode_base64($attachment_text);

  # The boundary string should always appear preceded by a pair of hyphen
  # characters. We might as well tack them on there now.
  $boundary = '--' . $boundary;

  # Put together the message: body text plus attachment text.
  my $multipart_message = <<"xxx_END_OF_BODY";
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$message
$boundary
Content-Type: application/octet-stream; name="$attachment_name"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$attachment_name"

$attachment_text
$boundary--
xxx_END_OF_BODY

  return ($multipart_message, $content_type);
}

#------------------------------------------------------------------------------
sub _compress_file_to_temp
# Compress the specified file to a temporary file.
#
# Returns the path of the temporary file, or undef on failure.
{
  my $file = shift or croak "No file specified.";

  # This is pretty futile, if the file is already compressed.
  croak "File $file is already compressed." if ($file =~ /\.tar\.gz$/o);

  # Get a temporary file path to compress to.
  my $temp_fh = File::Temp->new('UNLINK' => 0);
  my $temp_file = $temp_fh->filename();

  # Parse the file path into directory and filename.
  my($filename, $dir_path, undef) = File::Basename::fileparse($file);

  # Compress the file, working in the directory where the file lives.
  my $here = Cwd::getcwd();
  chdir($dir_path) or croak "Failed to move into directory $dir_path: $!";
  # N.B. Make sure that we always change the working directory back to what
  #      it used to be.
  eval {
    Xylem::Utils::File::create_archive($temp_file, [$filename], undef);
  };
  if ($@) {
    carp $@;
    undef($temp_file);
  }
  chdir($here) or croak "Failed to move into directory $here: $!";

  return $temp_file;
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
