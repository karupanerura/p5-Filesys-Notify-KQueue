# copied from Filesys::Notify::Simple and arrange
use strict;
use Filesys::Notify::KQueue;
use Test::More;
use Test::SharedFork;
use FindBin;

my $timeout = 6;
plan tests => 5;

my $w = Filesys::Notify::KQueue->new(
    path    => [ "lib", "t" ],
    timeout => $timeout,
);

my $pid = fork;
if ($pid == 0) {
    Test::SharedFork->child;
    sleep 1;
    my $test_file = "$FindBin::Bin/x/rm_create.data";
    open my $out, ">", $test_file;
    print $out "foo" . time;
    close $out;
    sleep 1;
    unlink $test_file;
} elsif ($pid != 0) {
    Test::SharedFork->parent;
    my $event_counter = 0;
    eval {
        local $SIG{ALRM} = sub { die 'timeout' };
        alarm $timeout;
        $w->wait(sub {
            die 'test_faild' if($event_counter >= 2);
            foreach my $event (@_) {
                $event_counter++;
                like $event->{path},  qr/rm_create\.data/, 'file';
                is   $event->{event}, (
                    ($event_counter == 1) ? 'create':
                    ($event_counter == 2) ? 'delete': die 'undefined'
                ), 'event';
            }
            die 'test_finish' if($event_counter == 2);
        });
        alarm 0;
    };
    pass('Test finish') if($@ =~ /^test_finish at/);

    waitpid $pid, 0;
} else {
    die $!;
}

