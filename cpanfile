requires 'File::Find';
requires 'IO::KQueue';

on build => sub {
    requires 'Carp';
    requires 'Exporter';
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'File::Path', '2.06_05';
    requires 'FindBin';
    requires 'IO::Handle';
    requires 'Test::More';
    requires 'Test::SharedFork';
    requires 'parent';
};
