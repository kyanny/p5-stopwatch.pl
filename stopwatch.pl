#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(HelpMessage);
use Time::HiRes qw(gettimeofday tv_interval);

GetOptions(
    '--initialize=s' => \my $initialize,
    '--before=s'     => \my $before,
    '--main=s'       => \my $main,
    '--after=s'      => \my $after,
    '--finalize=s'   => \my $finalize,
    '--count=i'      => \my $count,
    '--help'         => \&HelpMessage,
);
unless ($main) {
    HelpMessage();
}
unless ($count) {
    HelpMessage();
}
my $total;
my $ret;

print "Trying $count times... \n";
if ($initialize) {
    print "initializing...\n";
    `$initialize`;
}

for my $i (1..$count) {
    if ($before) {
        print "$i: run before hook...\n";
        `$before`;
    }

    my $start = [gettimeofday()];
    print "$i: run main...\n";
    `$main`;
    my $end = [gettimeofday()];
    my $elapsed = tv_interval($start, $end);
    print "$i: Elapsed: $elapsed\n";
    $total += $elapsed;
    

    if ($after) {
        print "$i: run after hook...\n";
        `$after`;
    }
}

if ($finalize) {
    print "finalizing...\n";
    `$finalize`;
}
print "Total: $total\n";

__END__

=head1 NAME

stopwatch.pl - 

=head1 SYNOPSIS

  $ ./stopwatch.pl \
      --initialize 'curl -O http://memcached.googlecode.com/files/memcached-1.4.9.tar.gz' \
      --before     'tar xzf memcached-1.4.9.tar.gz' \
      --main       'cd memcached-1.4.9 && ./configure && make' \
      --after      'cd memcached-1.4.9 && make clean' \
      --finalize   'rm -rf memcached-1.4.9 && rm memcached-1.4.9.tar.gz' \
      --count 10

=head1 DESCRIPTION



=cut

