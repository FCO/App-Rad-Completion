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
   my $prg_name = $1 if $new_prg =~ m{([^/]+)$};

   open my $progs, ">>", $prog_files;
   print {$progs} $prg_name, $/;
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

__END__

=head1 NAME

App::Rad::Completion - The great new App::Rad::Completion!

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

    app-rad-completion init ~/.bashrc
    . ~/.bashrc

=head1 COMMANDS

=head2 add_program

=head2 complete

=head2 generate

=head2 help

=head2 init

=head2 remove_program

=cut

=head1 AUTHOR

Fernando Correa de Oliveira, C<< <fco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-rad-completion at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Rad-Completion>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rad::Completion


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Rad-Completion>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Rad-Completion>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Rad-Completion>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Rad-Completion/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Fernando Correa de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
