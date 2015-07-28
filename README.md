

# Docker repository for Openfire Server

This provides a docker image for running
[Openfire Server](http://www.igniterealtime.org/projects/openfire/index.jsp).
This particular image is a litle unique in that in a couple ways:

* It uses an openfire.xml configuration file and an entrypoint.sh to
  manually configure the container instead of requiring the web UI
  configuration; this allows it to be used in places like Heroku and
  Aptible.

### Required Environment Variables

There are a few environment variables that should be set whenever
running this image; by setting them the configuration is updated
correctly for the database:

* `DB_HOST` - the host of the database to connect to; it will
  default to `DATABASE_PORT_5432_TCP_ADDR` if set.
* `DB_PORT` - the port of the database to connect to; it will
  default to `DATABASE_PORT_5432_TCP_PORT` if set.
* `DB_NAME` - the name of the database for holding openfire data; it will
  default to `openfire` if not set.
* `DB_USERNAME` - the username to connect to the database.
* `DB_PASSWORD` - the password to connect to the database.


## Running locally

You can run this locally by staring up a database container and then
linking into this image; __NOTE: We use the Aptible
[postgresql](https://github.com/aptible/docker-postgresql) image as it
supports SSL which is required in the Openfire config now.__

```
# Create a data volume for the data
docker create --name data quay.io/aptible/postgresql

# Initialize the DB's username, password and database
docker run --volumes-from data -e USERNAME=user1 -e PASSPHRASE=password1 -e DATABASE=openfire quay.io/aptible/postgresql --initialize

# Run the postgres server (we use the aptible image because it has SSL support)
docker run --name postgres1 --volumes-from data -d quay.io/aptible/postgresql

# Run once to prepare the db with required Openfire schema using a postgres image
docker run --rm --link postgres1:postgres --env PGPASSWORD=password1 --volume $(pwd)/openfire_postgresql.sql:/tmp/openfire_postgresql.sql postgres sh -c 'psql -h postgres -U user1 -d openfire -f /tmp/openfire_postgresql.sql'

# Run to start the server with ports exposed (use -p to expose to specific host ports)
docker run -d -P --link postgres1:database -e DB_NAME=openfire -e DB_USERNAME=user1 -e DB_PASSWORD=password1 prevailhs/openfire
```

**TODO: Add info about how to connect here.**

## Running in production

To run in production you should setup a database server in whatever methods you prefer,
then use the db Openfire schema to pre-load it; after that is complete
you can startup your server:

```
PGPASSWORD=password1 psql -h postgres -U user1 -d openfire -f openfire_postgresql.sql
docker run -d -P -e DB_HOST=1.2.3.4 -e DB_PORT=5432 -e DB_NAME=openfire -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword prevailhs/openfire
```

You should then be able to access (after a brief startup time) the
XMPP ports via whatever routing layer you're using.

# Contributing

Fork this repo and make PRs as normal. Feel free to knock off anything
on the TODO list.

## TODO

* Add a DB_SSL env var (default: true) that controls SSL connection to
  DB or not.
* Use official postgres image but figure out how to turn on SSL support.
* Add support for other DBs to be swapped in; probably leave PostgreSQL
  as the default but comment where people would alter after forking.
