use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;

use Test::More tests => 4;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

#-------------------------------------------------------------------

# insert user
my $user_data = {
    'login'    => time.'_user_004',
	'password' => 'password',
	'email'    => time.'_email_004@email.com',
};
my $user_response = $test->request(
	PUT '/user/request',
	Content_Type => 'application/json',
	Content => to_json($user_data)
);
my $last_user_id = from_json( $user_response->content )->{'id'};

#-------------------------------------------------------------------

# insert machine
my $machine_data = {
	'name'     => time.'_machine_004',
	'caffeine' => 100,
};
my $machine_response = $test->request(
	POST '/machine',
	Content_Type => 'application/json',
	Content => to_json($machine_data)
);
my $last_machine_id = from_json( $machine_response->content )->{'id'};

#-------------------------------------------------------------------

# nonexistent user-id
my $nonexistent_user_id = $last_user_id + 1;
my $response = $test->request(
	GET "/coffee/buy/$nonexistent_user_id/$last_machine_id",
);
is( $response->code, 400 );
like( $response->content, qr/This user-id does not exists/ );

#-------------------------------------------------------------------

# nonexistent machine-id
my $nonexistent_machine_id = $last_machine_id + 1;
$response = $test->request(
	GET "/coffee/buy/$last_user_id/$nonexistent_machine_id",
);
is( $response->code, 400 );
like( $response->content, qr/This machine-id does not exists/ );

#-------------------------------------------------------------------

done_testing();
