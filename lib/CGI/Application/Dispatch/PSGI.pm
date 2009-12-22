package CGI::Application::Dispatch::PSGI;
use strict;
use 5.008;

=head1 NAME

CGI::Application::Dispatch::PSGI - PSGI adapter for CGI::Application::Dispatch

=cut

our $VERSION = '0.1';

use base qw(CGI::Application::Dispatch);
use CGI::PSGI;

=head1 SYNOPSIS

CGI::Application::Dispatch is a (not so) simple dispatcher for
families of CGI::Application-based applications served under common
URL base.

It is a little too high-level to be directly converted to PSGI with
CGI::Application::PSGI so the need for a special adapter rose. Here it
is.

    ### in your Dispatch...
    use CGI::Application::Dispatch::PSGI;
    XXXX
    ...

=cut

=head1 GENERAL FUNCTIONS

=head2 as_psgi(\%args)

This is a constructor for PSGI application sub. It takes an optional
hashref with additional arguments for... XXX

Example:

    XXXX

=cut

sub as_psgi {
    my ($self, %args) = @_;

    return sub {
        my $output = do {
            no warnings 'redefine';
            local $ENV{CGI_APP_RETURN_ONLY} = 1;
            local *STDIN  = $env->{'psgi.input'};
            local *STDERR = $env->{'psgi.errors'};

            $args{args_to_new}->{QUERY} = CGI::PSGI->new(shift);
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

=head1 AUTHOR

Alex Kapranoff, C<< <kappa at cpan.org> >>

=head1 BUGS

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

=head1 COPYRIGHT & LICENSE

Copyright 2009 Alex Kapranoff.

This program is released under the following license: GPLv3

=cut

1;
