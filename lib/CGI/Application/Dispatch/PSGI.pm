package CGI::Application::Dispatch::PSGI;
use strict;
use 5.008;

our $VERSION = '0.1';

use base qw(CGI::Application::Dispatch);
use CGI::PSGI;

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

1;
