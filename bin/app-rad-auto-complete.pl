#!/usr/bin/perl

use App::Rad;
use strict;


package Not::On::Main;


sub create_string {
   my $name = shift;
   my $args = shift;

   my $sm = length $name == 1;

   my $sep = ($args ? ($sm ? "" : "=") : "");
   my $pre = ($sm ? "-" : "--");

   $pre . $name . $sep
}

sub create_opt {
   my $name   = shift;
   my $hash   = shift;

   my @ret;

   if($hash->{type} eq "bool") {
      $hash->{arguments} = 0
   } else {
      $hash->{arguments} = 1 unless defined $hash->{arguments};
   }
   push @ret, create_string($name, $hash->{arguments});

   if($hash->{aliases} and ref $hash->{aliases} eq "ARRAY") {
      for my $alias(@{ $hash->{aliases} }) {
         push @ret, create_string($alias, $hash->{arguments});
      }
   }
   @ret
}

sub get_prog_last_and_line {
   my $line = shift;
   
   $line =~ s/^\s+//;
   my $last;
   my $prog = $1
      if $line =~ /^\s*([^\s]+)\s*/;
   $last = $1
      if $line =~ s/([^\s]+)$//;
   ($prog, $last, $line);
}

package main;


my($prog, $last, $line) = Not::On::Main::get_prog_last_and_line(shift);

local @ARGV = split / /, $line;
shift @ARGV;

*App::Rad::_run_full_round = sub{
   my $c = shift;

   my @ret;
   if($last ne "=") {
      if(not $c->cmd) {
         push @ret, grep {/^$last/} $c->commands
      }

      my $cmd = $c->{'_commands'}->{ $c->cmd || "-global" };

      my @opts;

      for my $opt (keys %{ $cmd->{opts} }) {
         push @opts, Not::On::Main::create_opt($opt, $cmd->{opts}->{$opt});
      }
      @opts = grep {length $_ > 1} @opts if substr($last, 0, 2) eq "--";
      push @ret, grep {/^$last/} @opts;
      print join " ", @ret
   } else {
      print $/;
   }
};

do $prog
