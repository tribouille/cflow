#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Std;
use File::Temp;

sub get_proto
{
    my ($filename, $tab) = @_;

    open(my $fd, "<", $filename) or die " $!\n";
    while (my $line = <$fd>)
    {
	chomp $line;
	if ($line =~ /(\w*)\(\).*:(\d*)>$/)
	    {
		if (!defined(@{$$tab->{$1}}))
		{
		    push @{$$tab->{$1}}, $line;
		    push @{$$tab->{$1}}, $2;
		}
	    }
    }
    close $fd;
}

sub get_fun_call
{
    my ($filename, $funcs) = @_;

    open(my $fd, "<", $filename) or die " $!\n";

    while (my $line = <$fd>) {
	chomp $line;
	if ($line =~ /^(\w)\[(\w*)\] (.*):(\d*)$/) {
	    push @{$$funcs->{$3}->{$4}}, $2;
	    push @{$$funcs->{$3}->{$4}}, $1;
	}
    }
    close $fd;
}

sub sort_all
{
    my ($funcs) = @_;
    my $association = ();
    my $current = "";

    foreach my $tmp (keys %$funcs) {
		my $hash = $funcs->{$tmp};
		foreach my $tmp2 (sort {$a <=> $b} keys %$hash) {
			if ($hash->{$tmp2}->[1] eq "c") {
				push @{$association->{$current}}, $hash->{$tmp2}->[0];
			}
			elsif ($hash->{$tmp2}->[1] eq "d") {
				$current = $hash->{$tmp2}->[0];
			}
		}
    }

    return $association;
}

sub printer
{
    my ($proto, $hash, $current, $current_space, $no_double) = @_;
    my $used = {$current=>1};

    print "\t"x$current_space;
    if (defined($proto->{$current})) {
		print $proto->{$current}->[0];
    } else {
	print "$current() <$current (???)>";
    }

    if (grep(/^$current$/, @$no_double)) {
	print " (recursif)\n";
	return ;
    }
    print "\n";

    my $tab = $hash->{$current};
    return if !defined($tab);
    for (my $i=0; $i < scalar @$tab; ++$i) {
	push @$no_double, $current;
	printer($proto, $hash, $tab->[$i], $current_space + 1, $no_double) if (!defined($used->{$tab->[$i]}) || $used->{$tab->[$i]} == 0);
	$used->{$tab->[$i]} = 1;
	pop @$no_double;
    }
}

sub usage
{
    die "cflow.pl file [files]";
}

our $opt_i;
getopts("i:");
print Dumper $opt_i;

usage if ($#ARGV < 0);

my $funcs;
my $proto = undef;


my $cflow1Template = "/tmp/cflow.XXXXXX";
my $cflow2Template = "/tmp/cflow2.XXXXXX";

my ($cflow1Handler, $cflow1File) = File::Temp::mkstemp($cflow1Template);
close $cflow1Handler;

my ($cflow2Handler, $cflow2File) = File::Temp::mkstemp($cflow2Template);
close $cflow2Handler;

my $command = "lint -P $cflow1File -Q $cflow2File > /dev/null";
for (my $i=0; $i <= $#ARGV; ++$i) {
    $command .= " $ARGV[$i]";
}
    my $pid = fork();
    if ($pid == 0) {
	system($command);
	exit 0;
    } else {
	wait();
    }
get_proto $cflow1File, \$proto;
unlink($cflow1File);
die "Failed to parse this file!" if (!defined($proto));

get_fun_call $cflow2File, \$funcs;
unlink $cflow2File;
my $hash = sort_all $funcs;

my $no_double = ();
printer $proto, $hash, "main", 0, $no_double;
