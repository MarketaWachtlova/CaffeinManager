use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;
use DateTime;
use DateTime::Duration;

use Test::More tests => 5;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

#------------------------------------------------------------------------------

# insert user
my $user = {
    'login'    => time.'_user_002',
    'password' => 'password',
    'email'    => time.'_email_002@email.com',
};
my $user_response = $test->request(
    PUT '/user/request',
    Content_Type => 'application/json',
    Content => to_json($user)
);
my $user_id = from_json( $user_response->content )->{'id'};

#------------------------------------------------------------------------------

# insert machine
my $machine = {
    'name'     => time.'_machine_002',
    'caffeine' => 4096,
};
my $machine_response = $test->request(
    POST '/machine',
    Content_Type => 'application/json',
    Content => to_json($machine)
);
my $machine_id = from_json( $machine_response->content )->{'id'};

#------------------------------------------------------------------------------

# buy coffee before 24 hours
my $duration_24_hours = DateTime::Duration->new( hours => 24, );
my $timestamp = DateTime->now( time_zone => 'Europe/Prague' );
$timestamp->subtract_duration($duration_24_hours);

my $buy_response = $test->request(
    PUT "/coffee/buy/$user_id/$machine_id",
    Content_Type => 'application/json',
    Content => to_json({ timestamp => $timestamp->iso8601() })
);

#------------------------------------------------------------------------------

# check level stats
my $stat_response = $test->request(
    GET "/stats/level/user/$user_id",
);
ok( $stat_response->is_success, 'Successful request' );
my $stat_data = from_json( $stat_response->content );

# in time of intake
cmp_ok( $stat_data->{ $timestamp->iso8601() }, '==', 0 );

# after 1 hour
my $duration_1_hour  = DateTime::Duration->new( hours => 1, );
$timestamp->add_duration($duration_1_hour);
cmp_ok( $stat_data->{ $timestamp->iso8601() }, '==', $machine->{'caffeine'} );

# after 5 hours
my $duration_5_hours = DateTime::Duration->new( hours => 5, );
$timestamp->add_duration($duration_5_hours);
cmp_ok( $stat_data->{ $timestamp->iso8601() }, '==', $machine->{'caffeine'} / 2 );

# after next 5 hours
$timestamp->add_duration($duration_5_hours);
cmp_ok( $stat_data->{ $timestamp->iso8601() }, '==', $machine->{'caffeine'} / 4 );

#------------------------------------------------------------------------------

done_testing();
