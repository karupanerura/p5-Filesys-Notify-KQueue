package Filesys::Notify::KQueue;
use strict;
use warnings;
our $VERSION = '0.01';

use File::Find;
use IO::File;
use IO::KQueue;

sub default_timeout { 1 }

sub new {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };
    my $self  = bless(+{} => $class);

    $self->timeout($self->{timeout} || $class->default_timeout);
    $self->{_kqueue} = $args->{kqueue} if exists($args->{kqueue});
    $self->add(@{$args->{path}})       if exists($args->{path});

    return $self;
}

sub kqueue {
    my $self = shift;
    $self->{_kqueue} ||= IO::KQueue->new;
}

sub timeout {
    my $self = shift;
    (@_ == 1) ? ($self->{_timeout} = shift) : $self->{_timeout};
}

sub add {
    my $self = shift;

    foreach my $path (@_) {
        next if exists($self->{_files}{$path});
        if (-f $path) {
            $self->add_file($path);
        }
        elsif (-d $path) {
            $self->add_dir($path);
        }
        else {
            die "Unknown file '$path'";
        }
    }
}

sub add_file {
    my($self, $file) = @_;

    $self->{_files}{$file} = do {
        my $fh = IO::File->new($file, 'r') or die("Can't open '$file': $!");
        die "Can't get fileno '$file'" unless defined $fh->fileno;

        # add to watch
        $self->kqueue->EV_SET(
            $fh->fileno,
            EVFILT_VNODE,
            EV_ADD | EV_CLEAR,
            NOTE_DELETE | NOTE_WRITE | NOTE_RENAME | NOTE_REVOKE,
            0,
            $file,
        );

        $fh;
    };
}

sub add_dir {
    my($self, $dir) = @_;

    $self->add_file($dir);
    find(+{
        wanted => sub { $self->add($File::Find::name) },
        no_chdir => 1,
    }, $dir);
}

sub files { keys %{shift->{_files}} }

sub wait {
    my ($self, $cb) = @_;

    $self->kqueue->kevent($self->timeout);
    while (1) {
        my $events = $self->get_events;
        $cb->(@$events) if(@$events);
    }
}

sub get_events {
    my $self = shift;

    my @kevents = $self->kqueue->kevent($self->timeout);

    my @events;
    foreach my $kevent (@kevents) {
        my $path  = $kevent->[KQ_UDATA];
        my $flags = $kevent->[KQ_FFLAGS];

        if(($flags & NOTE_DELETE) or ($flags & NOTE_RENAME)) {
            my $event = ($flags & NOTE_DELETE) ? 'delete' : 'rename';
            push(@events, +{
                event => $event,
                path  => $path,
            });
            if (-d $path) {
                foreach my $stored_path ( $self->files ) {
                    next if $stored_path !~ /^$path/;
                    delete($self->{_files}{$stored_path});
                    push(@events, +{
                        event => $event,
                        path  => $path,
                    });
                }
            }
        }
        elsif ($flags & NOTE_WRITE) {
            if (-f $path) {
                push(@events, +{
                    event => 'modify',
                    path  => $path,
                });
            }
            elsif (-d $path) {
                find(+{
                    wanted => sub {
                        return if exists($self->{_files}{$File::Find::name});
                        push(@events, +{
                            event => 'create',
                            path  => $File::Find::name,
                        });
                        $self->add($File::Find::name);
                    },
                    no_chdir => 1,
                }, $path);
            }
        }
    }

    return \@events;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Filesys::Notify::KQueue - Wrap IO::KQueue for watching file system.

=head1 SYNOPSIS

  use Filesys::Notify::KQueue;

  my $notify = Filesys::Notify::KQueue->new(
      path    => [qw(~/Maildir/new)],
      timeout => 1,
  );
  $notify->watch(sub {
      my @events = @_;

      foreach my $event (@events) {
          ## ....
      }
  });

=head1 DESCRIPTION

Filesys::Notify::KQueue is IO::KQueue wrapper for watching file system.

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

L<IO::KQueue> L<Filesys::Notify::Simple> L<AnyEvent::Filesys::Notify> L<File::ChangeNotify> L<Mac::FSEvents> L<Linux::Inotify2>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
