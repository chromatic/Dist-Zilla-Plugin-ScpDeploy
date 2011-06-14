package Dist::Zilla::Plugin::ScpDeploy;
# ABSTRACT: deploy via scp and ssh

use Moose 2.0007;
use Moose::Util::TypeConstraints;

use namespace::autoclean;

with 'Dist::Zilla::Role::Releaser';

coerce 'ArrayRef[Str]', from 'Str', via { [ split /,\s*/, $_ ] };

has [qw( remote_dir command )],      is => 'ro', required => 1;
has 'hosts', isa => 'ArrayRef[Str]', is => 'ro', required => 1, coerce => 1;

sub release
{
    my ($self, $archive) = @_;
    my $remote_dir       = $self->remote_dir;
    my $command          = $self->command;

    for my $host (@{ $self->hosts })
    {
        system( 'scp', $archive, "${host}:${remote_dir}" );
        system( 'ssh', $host, $command,  "${remote_dir}/${archive}" );
    }
}

__PACKAGE__->meta->make_immutable;

=head1 DESCRIPTION

This plugin can automatically deploy a release when you run C<dist release>. It
performs two actions for you:

=over 4

=item * uses C<scp> to copy the released tarball to one or more hosts

=item * uses C<ssh> to run a deployment command on each of those hosts

=back

Configure this behavior in your F<dist.ini> by setting three required
arguments:

  [ScpDeploy]
  hosts      = huey, dewey, louie
  command    = release_me
  remote_dir = /home/cbarks/vault

Note well that you may specify multiple hosts by separating them with commas
and (optional) spaces.

It is your responsibility to configure C<ssh> and C<scp> on your machine such
that hostnames and passwordless logins work correctly I<and> that this module
can find the appropriate binaries in your path. It is also your responsibility
to configure the remote hosts such that the remote directory and the remote
command to run are available.

The remote command receives one argument: the path to the release tarball in
the give remote directory.
