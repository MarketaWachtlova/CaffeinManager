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

# NaN user-id
my $user_id    = 'x';
my $machine_id = 1;
my $response = $test->request(
	GET "/coffee/buy/$user_id/$machine_id",
);
is( $response->code, 400 );
like( $response->content, qr/must be a number/ );

#-------------------------------------------------------------------

# NaN machine-id
$user_id    = 1;
$machine_id = 'x';
$response = $test->request(
	GET "/coffee/buy/$user_id/$machine_id",
);
is( $response->code, 400 );
like( $response->content, qr/must be a number/ );

#-------------------------------------------------------------------

done_testing();
