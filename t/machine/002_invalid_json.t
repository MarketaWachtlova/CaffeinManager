use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use Storable qw(dclone);
use CaffeineManager;

use Test::More tests => 2;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

# request
my $response = $test->request( 
	POST '/machine',
	Content_Type => 'application/json',
	Content => ''
);

is( $response->code, 400 );
like( $response->content, qr/Wrong JSON format/ );

done_testing();
