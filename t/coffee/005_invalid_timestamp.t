use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;

use Test::More tests => 14;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

#-------------------------------------------------------------------

# insert user
my $user_data = {
    'login'    => time.'_user_005',
    'password' => 'password',
    'email'    => time.'_email_005@email.com',
};
my $user_response = $test->request(
    PUT '/user/request',
    Content_Type => 'application/json',
    Content => to_json($user_data)
);
my $user_id = from_json( $user_response->content )->{'id'};

#-------------------------------------------------------------------

# insert machine
my $machine_data = {
    'name'     => time.'_machine_005',
    'caffeine' => 100,
};
my $machine_response = $test->request(
    POST '/machine',
    Content_Type => 'application/json',
    Content => to_json($machine_data)
);
my $machine_id = from_json( $machine_response->content )->{'id'};

#-------------------------------------------------------------------

# buy
my @invalid_timestamps = (
    '2018--18T06:42:16+00:00',
    '208T06:42:16+00:00',
    '2018-07-1806:42:16+00:00',
    '2018-07-18T',
    '2018-07-18A06:42:16+00:00',
    '2018-07-18T06:42:99',
    '2018-97-18T06:42:99',
);

for ( @invalid_timestamps ){
    my $response = $test->request(
        PUT "/coffee/buy/$user_id/$machine_id",
        Content_Type => 'application/json',
        Content => to_json({ timestamp => $_ })
    );

    is( $response->code, 400 );
    like( $response->content, qr/Wrong time format \(ISO 8601 is required\)/ );
}

#-------------------------------------------------------------------

done_testing();
