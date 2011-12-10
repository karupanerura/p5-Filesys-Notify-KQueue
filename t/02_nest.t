use strict;
use warnings;
use Filesys::Notify::KQueue;
use Test::More tests => 2;
use Test::SharedFork;
use File::Find;
use File::Path qw/remove_tree/;
use FindBin;

my $dir = 't/x';
my $w = Filesys::Notify::KQueue->new(path => [$dir]);
my @files;
find +{
    wanted => sub { push @files => $File::Find::name },
    no_chdir => 1,
} => $dir;

is_deeply [sort $w->files] => [sort @files], 'watching all file';

my $sleep_time = 3;
my @test_paths = (
    "$FindBin::Bin/x/rm_create.data",
    "$FindBin::Bin/x/nest/",
    "$FindBin::Bin/x/nest/1",
    "$FindBin::Bin/x/nest/2",
    "$FindBin::Bin/x/nest/nest/",
    "$FindBin::Bin/x/nest/nest/1",
    "$FindBin::Bin/x/nest/nest/2",
);

my $pid = fork;
if ($pid == 0) {
    Test::SharedFork->child;
    sleep  $sleep_time;
    create_paths(@test_paths);
    sleep  $sleep_time;
    delete_paths(@test_paths);
    exit(0);
}
elsif ($pid != 0) {
    Test::SharedFork->parent;
    my $event;
    foreach (1..2) {
        alarm $sleep_time + 3;
        $w->wait(sub {
            foreach my $event (@_) {
                my $path = $event->{path};
                if ($event->{event} eq 'create') {
                    push @files => $path;
                }
                elsif ($event->{event} eq 'delete' or $event->{event} eq 'rename') {
                    @files = grep { $_ ne $path } @files;
                }
                note explain $event;
            }
            note explain[$w->files];
            is_deeply [sort $w->files] => [sort @files], 'files update';
        });
        alarm 0;
        sleep $sleep_time + 1;
    }
    waitpid $pid, 0;
}
else {
    die $!;
}

sub create_paths {
    my @test_paths = @_;

    foreach my $test_path (@test_paths) {
        if ($test_path =~ m{/$}) {
            mkdir $test_path;
        }
        else {
            open my $fh, ">", $test_path or die $!;
            print $fh "foo" . time;
            close $fh;
        }
    }
}

sub delete_paths {
    my @test_paths = @_;

    foreach my $test_path (reverse @test_paths) {
        if (-d $test_path) {
            remove_tree $test_path;
        }
        else {
            unlink $test_path;
        }
    }
}
