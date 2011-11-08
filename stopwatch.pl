#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(HelpMessage);
use Time::HiRes qw(gettimeofday tv_interval);
use File::Basename;
use List::Util qw(sum);

our $VERSION = '0.01';

GetOptions(
    'initialize=s' => \my $initialize,
    'before=s'     => \my $before,
    'main=s'       => \my $main,
    'after=s'      => \my $after,
    'finalize=s'   => \my $finalize,
    'count=i'      => \my $count,
    'v|verbose+'   => \my $verbose,
    'version'      => sub {
        print basename($0) . '/' . $VERSION . "\n";
        exit;
    },
    'help'         => \&HelpMessage,
);
unless ($main) {
    HelpMessage();
}
unless ($count) {
    HelpMessage();
}

$verbose ||= 0;
my $verbose_level_1 = $verbose > 0;
my $verbose_level_2 = $verbose > 1;

my @results;
my $total;
my $average;
my $ret;

#----
sub initialize {
    info('initializing...');

    $ret = `$initialize`;
    debug($ret);
}

sub before {
    info('run before hook...');

    $ret = `$before`;
    debug($ret);
}

sub main {
    my $start = [gettimeofday()];
    info('run main...');

    $ret = `$main`;
    debug($ret);

    my $end = [gettimeofday()];
    my $elapsed = tv_interval($start, $end);
    push @results, $elapsed;

    print $elapsed, "\n";
}

sub after {
    info('run after hook...');

    $ret = `$after`;
    debug($ret);
}

sub finalize {
    info('finalizing...');

    $ret = `$finalize`;
    debug($ret);
}

#----
sub info {
    print @_, "\n" if $verbose_level_1;
}

sub debug {
    print @_, "\n" if $verbose_level_2;
}

#----
print "Trying $count times... \n";
initialize() if $initialize;

for my $i (1..$count) {
    before() if $before;

    print "==> $i/$count ... ";
    main();

    after() if $after;
}

finalize() if $finalize;

$total = sum @results;
$average = $total / $count;
print "Total: $total\n";
print "Average: $average\n";


__END__

=head1 NAME

stopwatch.pl - 

=head1 SYNOPSIS

  $ ./stopwatch.pl \
      --initialize 'curl -Os http://memcached.googlecode.com/files/memcached-1.4.9.tar.gz' \
      --before     'tar xzf memcached-1.4.9.tar.gz' \
      --main       'cd memcached-1.4.9 && ./configure && make' \
      --after      'cd memcached-1.4.9 && make clean' \
      --finalize   'rm -rf memcached-1.4.9 && rm memcached-1.4.9.tar.gz' \
      --count 10

  Options:
    --verbose
    --version
    --help

=head1 DESCRIPTION



=cut

