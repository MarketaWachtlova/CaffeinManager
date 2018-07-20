use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use Storable qw(dclone);
use CaffeineManager;

use Test::More tests => 6;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

# users data
my $user_data = {
	'login'    => time.'_user_003',
	'password' => 'password',
	'email'    => time.'_email_003@email.com',
};

# request
for ( 'login', 'password', 'email' ){
	my $tmp_user = dclone $user_data;
	delete $tmp_user->{$_};

	my $response = $test->request( 
		PUT '/user/request',
		Content_Type => 'application/json',
		Content => to_json($tmp_user)
	);

	is( $response->code, 400 );
	like( $response->content, qr/Missing mandatory param: $_/ );
}

done_testing();
