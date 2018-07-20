use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;

use Test::More tests => 12;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

# users data
my $user = {
	'login'    => time.'_user_005',
	'password' => 'password',
};

my @invalid_emails = (
	'',
	time.'_email',
	time.'_email@',
	time.'_email@email',
	time.'_email@email.',
	time.'_email@email@email.com',
);

# request
for ( @invalid_emails ){
	$user->{'email'} = $_;

	my $response = $test->request( 
		PUT '/user/request',
		Content_Type => 'application/json',
		Content => to_json($user)
	);

	is( $response->code, 400 );
	like( $response->content, qr/The email is not valid/ );
}

done_testing();
