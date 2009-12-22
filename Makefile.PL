use inc::Module::Install;

name     'CGI-Application-Dispatch-PSGI';
all_from 'lib/CGI/Application/Dispatch/PSGI.pm';
author   'Alex Kapranoff <kappa@cpan.org>';

build_requires 'Test::More';

auto_install;

WriteAll;

