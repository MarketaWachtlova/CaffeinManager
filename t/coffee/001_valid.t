use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;

use Test::More tests => 2;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

#-------------------------------------------------------------------

# insert user
my $user_data = {
    'login'    => time.'_user_001',
	'password' => 'password',
	'email'    => time.'_email_001@email.com',
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
	'name'     => time.'_machine_001',
	'caffeine' => 100,
};
my $machine_response = $test->request(
	POST '/machine',
	Content_Type => 'application/json',
	Content => to_json($machine_data)
);
my $machine_id = from_json( $machine_response->content )->{'id'};

#-------------------------------------------------------------------

# buy now
my $response_now = $test->request(
	GET "/coffee/buy/$user_id/$machine_id",
);
ok( $response_now->is_success, 'Successful request' );

#-------------------------------------------------------------------

# buy at time
my $time = '2018-07-18T06:42:16+00:00';
my $response_at_time = $test->request(
	PUT "/coffee/buy/$user_id/$machine_id",
	Content_Type => 'application/json',
	Content => to_json({ timestamp => $time })
);
ok( $response_at_time->is_success, 'Successful request' );

#-------------------------------------------------------------------

done_testing();
