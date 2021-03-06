use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Rad::Completion',
    AUTHOR              => q{Fernando Correa de Oliveira <fco@cpan.org>},
    VERSION_FROM        => 'lib/App/Rad/Completion.pm',
    ABSTRACT_FROM       => 'lib/App/Rad/Completion.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    EXE_FILES           => ["bin/app-rad-completion"]
    PREREQ_PM => {
        'Test::More' => 0,
        'App::Rad'   => 1.05,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-Rad-Completion-*' },
);
