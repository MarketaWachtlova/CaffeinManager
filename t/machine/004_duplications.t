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
my $valid_machine = {
	'name'     => time.'_machine_004',
	'caffeine' => 100,
};

# first request
my $response = $test->request(
	POST '/machine',
	Content_Type => 'application/json',
	Content => to_json($valid_machine)
);

# duplicate request
$response = $test->request( 
	POST '/machine',
	Content_Type => 'application/json',
	Content => to_json($valid_machine)
);
is( $response->code, 400 );
like( $response->content, qr/already exists/ );

done_testing();
