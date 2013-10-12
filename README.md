# NAME

Filesys::Notify::KQueue - Wrap IO::KQueue for watching file system.

# SYNOPSIS

    use Filesys::Notify::KQueue;

    my $notify = Filesys::Notify::KQueue->new(
        path    => [qw(~/Maildir/new)],
        timeout => 1000,
    );
    $notify->wait(sub {
        my @events = @_;

        foreach my $event (@events) {
            ## ....
        }
    });

# DESCRIPTION

Filesys::Notify::KQueue is IO::KQueue wrapper for watching file system.

# METHODS

## new - Hash or HashRef

This is constructor method.

- path - ArrayRef\[Str\]

    Watch files or directories.

- timeout - Int

    KQueue's timeout. (millisecond)

## wait - CodeRef

There is no file name based filter. Do it in your own code.
You can get types of events (create, modify, rename, delete).

# AUTHOR

Kenta Sato <karupa@cpan.org>

# SEE ALSO

[IO::KQueue](http://search.cpan.org/perldoc?IO::KQueue) [Filesys::Notify::Simple](http://search.cpan.org/perldoc?Filesys::Notify::Simple) [AnyEvent::Filesys::Notify](http://search.cpan.org/perldoc?AnyEvent::Filesys::Notify) [File::ChangeNotify](http://search.cpan.org/perldoc?File::ChangeNotify) [Mac::FSEvents](http://search.cpan.org/perldoc?Mac::FSEvents) [Linux::Inotify2](http://search.cpan.org/perldoc?Linux::Inotify2)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
