#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Rad::Completion' ) || print "Bail out!\n";
}

diag( "Testing App::Rad::Completion $App::Rad::Completion::VERSION, Perl $], $^X" );
