package App::Rad::Completion;
use App::Rad;
use Carp;
use strict;

my $prog_files = "$ENV{HOME}/.app-rad-commands";

sub remove_app_rad_prog {
   my $self    = shift;
   my $del_prg = shift;

   open my $progs_r, "<", $prog_files;
   open my $progs_w, ">", $prog_files;
   print {$progs_w} $_, $/ for grep {$_ ne $del_prg} <$progs_r>;
}

sub new_app_rad_prog {
   my $self    = shift;
   my $new_prg = shift;

   croak "File '$new_prg' does not exists" unless -f $new_prg;

   open my $progs, ">>", $prog_files;
   print {$progs} $new_prg, $/;
}

sub create_string {
   my $self = shift;
   my $name = shift;
   my $args = shift;

   my $sm = length $name == 1;

   my $sep = ($args ? ($sm ? "" : "=") : "");
   my $pre = ($sm ? "-" : "--");

   $pre . $name . $sep
}

sub create_opt {
   my $self = shift;
   my $name = shift;
   my $hash = shift;

   my @ret;

   if($hash->{type} eq "bool") {
      $hash->{arguments} = 0
   } else {
      $hash->{arguments} = 1 unless defined $hash->{arguments};
   }
   push @ret, $self->create_string($name, $hash->{arguments});

   if($hash->{aliases} and ref $hash->{aliases} eq "ARRAY") {
      for my $alias(@{ $hash->{aliases} }) {
         push @ret, $self->create_string($alias, $hash->{arguments});
      }
   }
   @ret
}

sub get_prog_last_and_line {
   my $self = shift;
   my $line = shift;
   
   $line =~ s/^\s+//;
   my $last;
   my $prog = $1
      if $line =~ /^\s*([^\s]+)\s*/;
   $last = $1
      if $line =~ s/([^\s]+)$//;
   ($prog, $last, $line);
}

sub do_completion {
   my $self = shift;
   my $line = shift;
   my($prog, $last, $line) = __PACKAGE__->get_prog_last_and_line($line);
   
   local $\ = $/;
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
            push @opts, App::Rad::Completion->create_opt($opt, $cmd->{opts}->{$opt});
         }
         @opts = grep {length $_ > 1} @opts if substr($last, 0, 2) eq "--";
         push @ret, grep {/^$last/} @opts;
         print join " ", @ret
      } else {
         print;
      }
   };
   
   package main;
   do $prog
}

42
