requires 'IO::KQueue';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
    requires 'perl', '5.008_001';
};

on test => sub {
    requires 'Test::More';
    requires 'Test::SharedFork';
    requires 'parent';
    requires 't::Util';
};

on develop => sub {
    requires 'Test::Perl::Critic';
};
