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

# machine data
my $machine_data = {
	'name'     => time.'_machine_001',
	'caffeine' => 100,
};

# request
my $response = $test->request(
	POST '/machine',
	Content_Type => 'application/json',
	Content => to_json($machine_data)
);
ok( $response->is_success, 'Successful request' );
like $response->content, qr/id/;

done_testing();
