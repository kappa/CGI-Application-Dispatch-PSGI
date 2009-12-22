package CGI::Application::Dispatch::PSGI;
use strict;
use 5.008;

=head1 NAME

CGI::Application::Dispatch::PSGI - PSGI adapter for CGI::Application::Dispatch

=cut

our $VERSION = '0.1';

use CGI::Application::Dispatch ();
use CGI::PSGI;

=head1 SYNOPSIS

CGI::Application::Dispatch is a (not so) simple dispatcher for
families of CGI::Application-based applications served under common
URL base.

It is a little too high-level to be directly converted to PSGI with
CGI::Application::PSGI so the need for a special adapter rose. Here it
is.

    ### in your dispatch.psgi:
    use Your::Application::Dispatch;
    use CGI::Application::Dispatch::PSGI;

    Your::Application::Dispatch->as_psgi;

Most of CGI::Application::Dispatch scripts may be converted by
simply changing C<dispatch()> method call to C<as_psgi()> call.

The code is a mere mashup of L<CGI::Application::PSGI> and
L<CGI::Application::Emulate::PSGI>, so all the good parts here are
courtesy of their respective authors but the bugs are all mine.

=cut

=head1 INTERFACE

When you "use" this package it installs a single additional method
C<as_psgi> into CGI::Application::Dispatch which is immediately
available to your custom dispatcher class through inheritance.

=head2 as_psgi(%args)

This is a constructor for PSGI application sub. It must be called as a
method and takes an optional hash with arguments for dispatcher. For
additional information about the arguments, see
L<CGI::Application::Dispatcher/dispatch(%args)>.

Example:

    my $app = MyApp::CAP::Dispatch->as_psgi(
        args_to_new => {
            PARAMS => {
                cfg_file => "$cfgdir/myapp.cfg",
            },
        },
    );

=cut

sub as_psgi {
    my ($self, %args) = @_;

    return sub {
        my $env = shift;

        my $output = do {
            no warnings 'redefine';
            local $ENV{CGI_APP_RETURN_ONLY} = 1;
            local *STDIN  = $env->{'psgi.input'};
            local *STDERR = $env->{'psgi.errors'};

            $args{args_to_new}->{QUERY} = CGI::PSGI->new(shift);
            local $ENV{PATH_INFO} = $env->{PATH_INFO};
            $self->dispatch(%args);
        };

        my $status = 200;
        my ($headers, $body) = split /\r?\n\r?\n/, $output, 2;
        my @headers = map { split /:\s*/, $_, 2 } split /\r?\n/, $headers;
        for (my $i = 0; $i < @headers;) {
            if ($headers[$i] =~ /^status$/i) {
                $status = $headers[$i + 1];
                $status =~ s/\s+.*$//; # only keep the digits
                splice @headers, $i, 2;
            } else {
                $i += 2;
            }
        }

        return [
            $status,
            \@headers,
            [ $body ],
        ];
    };
}

sub import {
    no strict 'refs';
    *{CGI::Application::Dispatch::as_psgi} = \&as_psgi;
}

=head1 AUTHOR

Alex Kapranoff, C<< <kappa at cpan.org> >>

=head1 BUGS

CGI::Application::Dispatch::PSGI was NOT tested under mod_perl.
Patches (if need arises) are welcome.

This module was made to use Plack's middlewares during debugging and
was never run in production. CGI::Application::Dispatch should really
rely less on %ENV.

Please report any bugs or feature requests to C<bug-cgi-application-dispatch-psgi at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CGI-Application-Dispatch-PSGI>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CGI::Application::Dispatch::PSGI

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CGI-Application-Dispatch-PSGI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CGI-Application-Dispatch-PSGI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CGI-Application-Dispatch-PSGI>

=item * Search CPAN

L<http://search.cpan.org/dist/CGI-Application-Dispatch-PSGI>

=back

=head1 SEE ALSO

L<http://plackperl.org>, L<CGI::Application::PSGI>,
L<CGI::Application::Emulate::PSGI>, L<CGI::Application::Dispatch::Server>.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Alex Kapranoff.

This program is released under the following license: GPLv3

=cut

1;
