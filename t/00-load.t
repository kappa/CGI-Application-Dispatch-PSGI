#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'CGI::Application::Dispatch::PSGI' );
}

diag( "Testing CGI::Application::Dispatch::PSGI $CGI::Application::Dispatch::PSGI::VERSION, Perl $], $^X" );
