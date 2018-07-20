use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'CaffeineManager',
    AUTHOR              => q{Marketa Wachtlov <marketa.wachtlova@gmail.com>},
    VERSION_FROM        => 'lib/CaffeineManager.pm',
    ABSTRACT            => 'The Caffeine Manager allows its users to manage '
                          . 'and monitor their caffeine intoxication and helps '
                          . 'them to administer their caffeine level',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Dancer2'                     => 0.200002,
        'Dancer2::Plugin::Passphrase' => 3.3.0,
        'Dancer2::Plugin::Pg'         => 0.07,
        'DateTime'                    => 1.49,
        'DateTime::Duration'          => 1.49,
        'DateTime::Format::ISO8601'   => 0.08,
        'Email::Valid'                => 1.198,
        'English'                     => 1.09,
        'ExtUtils::MakeMaker'         => 7.34,
        'FindBin'                     => 1.51,
        'HTTP::Request::Common'       => 6.11,
        'JSON'                        => 2.90,
        'Plack::Test'                 => 0,
        'Readonly'                    => 2.05,
        'Scalar::Util'                => 1.5,
        'Storable'                    => 2.53_01,
        'Test::More'                  => 1.302138,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'CaffeineManager-*' },
    test => { TESTS => 't/*/*.t'}
);
