#!/usr/bin/perl
use App::Rad;

sub test{"test"}

App::Rad->run;

sub setup{
   my $c = shift;

   $c->register(
                'app' => \&app,
                      {
                       rewrite => {
                                   type      => "str",
                                   condition => sub{
                                                    my @funcs = split /,/, shift;
                                                    @funcs == grep {m/^(?:setup|pre_process|post_process|default|invalid)$/}
                                                       @funcs;
                                                   },
                                   error_msg => "func not recognized",
                                   to_stash  => ["funcs"],
                                   aliases   => [qw/funcs func function f/],
                                   help      => "Funcs to rewrite"
                                  },
                       commands => {
                                    type      => "str",
                                    error_msg => "must be a list of commands",
                                    to_stash  => ["commands"],
                                    aliases   => [qw/command cmds cmd c/],
                                    help      => "List of commands",
                                    conflicts_with => ["plugins"]
                                  },
                       plugins => {
                                   type      => "str",
                                   error_msg => "must be a list of plugins",
                                   to_stash  => ["plugins"],
                                   aliases   => [qw/plugin p/],
                                   help      => "List of plugins"
                                  },
                       funfou  => {
                                   #type      => "bool",
                                   arguments => 0,
                                   to_stash  => ["funfou"],
                                   aliases   => [qw/funfa/],
                                   help      => "Funfou"
                                  },
                      },
               );

}

sub app{}
