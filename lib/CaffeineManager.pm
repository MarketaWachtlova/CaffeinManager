package CaffeineManager;

use strict;
use warnings;
use Dancer2;

use CaffeineManager::User;
use CaffeineManager::Machine;
use CaffeineManager::Coffee;
use CaffeineManager::Stats;

our $VERSION = '0.1';

# register user/machine
put 'user/request' => \&CaffeineManager::User::register;
post 'machine'     => \&CaffeineManager::Machine::register;

# buy coffee
get 'coffee/buy/:user-id/:machine-id' => \&CaffeineManager::Coffee::buy_now;
put 'coffee/buy/:user-id/:machine-id' => \&CaffeineManager::Coffee::buy_at_time;

# show stats
get 'stats/coffee'             => \&CaffeineManager::Stats::get_stats;
get 'stats/coffee/machine/:id' => \&CaffeineManager::Stats::get_machine_stats;
get 'stats/coffee/user/:id'    => \&CaffeineManager::Stats::get_user_stats;
get 'stats/level/user/:id'     => \&CaffeineManager::Stats::get_level_stats;

# error into json
hook after_error => sub {
    my ($args) = @_;

    $args->{'content'} = to_json(
        {
            'error_code' => $args->{'status'},
            'error_text' => ( $args->{'status'} eq '404' )
                            ? 'Not found'
                            : q{}
        }
    );
};

1;
