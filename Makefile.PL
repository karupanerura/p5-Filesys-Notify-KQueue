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

test_requires 'Test::More';
test_requires 'Test::SharedFork';
test_requires 'File::Path';
test_requires 'File::Find';
test_requires 'FindBin';

auto_set_repository;
WriteAll;
