# The Caffeine Manager
The Caffeine Manager allows its users to manage and monitor their caffeine intoxication and helps them to administer their caffeine level

## Author
Markéta Wachtlová

## The Deployment

### Install the required Perl modules
**cpanfile** specifies exact modules versions

### Install PostgreSQL DBMS
[Installation guides](https://wiki.postgresql.org/wiki/Detailed_installation_guides)

### Create the database and the tables
```bash
psql < create.sql
```

### Define your database connection details in config.yml
```yaml
plugins:
    Pg:
        host: 'localhost'
        port: '5432'
        base: 'caffeine_manager'
        username: ''
        password: ''
```

## Usage

### Run the app - start Dancer's standalone server
```bash
plackup -r bin/app.psgi
```

### Run tests
```bash
perl Makefile.PL
make test
```

### Send a request
#### Examples:
##### Register a user
```bash
curl -X PUT -H "Content-Type: application/json" -d '{"login":"login", "email":"email@email.com","password":"password"}' http://0.0.0.0:5000/user/request
```

##### Register a machine
```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"name", "caffeine":12}' http://0.0.0.0:5000/machine
```

##### Buy a coffee
```bash
curl http://0.0.0.0:5000/coffee/buy/1/1
```

##### Get stats
```bash
curl http://0.0.0.0:5000/stats/level/user/1
```


## The assignment details

Every POST/PUT request accepts json object with keys described below.
Every request returns json object with
          * status 200 with described keys on success
          * status 4xx with optional json error object with mandatory keys
		* error_code
		* error_text

`PUT /user/request`
* arg keys
	* login - mandatory, unique
	* password - mandatory
	* email - mandatory, unique
* result keys
	* id

`POST /machine`
* registry machine
	* name
	* caffeine - mg per cup
* returns
	* id

`GET /coffee/buy/:user-id/:machine-id`
* registry coffee bought by user at current time

`PUT /coffee/buy/:user-id/:machine`
* similar to GET but use given timestamp
* args
	* timestamp - iso-8601 timestamp

`GET /stats/coffee`
`GET /stats/coffee/machine/:id`
`GET /stats/coffee/user/:id`
* return history of user transactions per user/machine/ or global
* list of objects with
	* machine - object with name and id keys
	* user - object with login and id keys
	* timestamp

`GET /stats/level/user/:id`
* return caffeine level history of user
* let’s assume that caffeine level
	* increases linearly from 0 to 100% in first hour
	* is reduced afterwards by half every 5 hour
* return list of levels for past 24 hour using 1h resolution
