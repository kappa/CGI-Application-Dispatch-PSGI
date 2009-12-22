use inc::Module::Install;

name     'CGI-Application-Dispatch-PSGI';
all_from 'lib/CGI/Application/Dispatch/PSGI.pm';

requires 'CGI::PSGI';
requires 'CGI::Application::Dispatch';

test_requires 'Test::More';

license 'gpl';

WriteAll;
