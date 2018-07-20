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

# users data
my $valid_user = {
	'login'    => time.'_user_004',
	'password' => 'password',
	'email'    => time.'_email_004@email.com',
};

# first request
my $response = $test->request( 
	PUT '/user/request',
	Content_Type => 'application/json',
	Content => to_json($valid_user)
);

# duplicate request
$response = $test->request( 
	PUT '/user/request',
	Content_Type => 'application/json',
	Content => to_json($valid_user)
);
is( $response->code, 400 );
like( $response->content, qr/already exists/ );

done_testing();
