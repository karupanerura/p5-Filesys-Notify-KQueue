use inc::Module::Install;
name 'Filesys-Notify-KQueue';
all_from 'lib/Filesys/Notify/KQueue.pm';
readme_from 'lib/Filesys/Notify/KQueue.pm';
readme_pod_from 'lib/Filesys/Notify/KQueue.pm';
githubmeta;

requires 'IO::KQueue';
requires 'File::Find';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
