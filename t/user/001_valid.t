use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;

use Test::More tests => 4;

# create an application
use_ok 'CaffeineManager';
my $app = CaffeineManager->to_app;
isa_ok( $app, 'CODE' );

# create a testing object
my $test = Plack::Test->create($app);

# users data
my $valid_user = {
	'login'    => time.'_user_001',
	'password' => 'password',
	'email'    => time.'_email_001@email.com',
};

# request
my $response = $test->request(
	PUT '/user/request',
	Content_Type => 'application/json',
	Content => to_json($valid_user)
);
ok( $response->is_success, 'Successful request' );
like $response->content, qr/id/;

done_testing();
