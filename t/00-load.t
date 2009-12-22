#!perl -T

use Test::More tests => 4;

BEGIN {
	use_ok( 'CGI::Application::Dispatch::PSGI' );
}

diag( "Testing CGI::Application::Dispatch::PSGI $CGI::Application::Dispatch::PSGI::VERSION, Perl $], $^X" );

can_ok('CGI::Application::Dispatch::PSGI', 'as_psgi');
can_ok('CGI::Application::Dispatch', 'as_psgi');

is(CGI::Application::Dispatch->can('as_psgi'),
    CGI::Application::Dispatch::PSGI->can('as_psgi'));
