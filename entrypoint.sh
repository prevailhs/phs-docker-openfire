#!/bin/bash
set -e

# Get the DB_HOST and DB_PORT from docker linking if not set
# TODO: Add support for other DBs
: ${DB_HOST:=${DATABASE_PORT_5432_TCP_ADDR}}
: ${DB_PORT:=${DATABASE_PORT_5432_TCP_PORT}}
: ${DB_NAME:="openfire"}

# Make corrections in /usr/share/openfire/conf/openfire.xml
CONF_FILENAME=/usr/share/openfire/conf/openfire.xml
sed -i "s/db_host_to_replace/$DB_HOST/g" ${CONF_FILENAME}
sed -i "s/db_port_to_replace/$DB_PORT/g" ${CONF_FILENAME}
sed -i "s/db_name_to_replace/$DB_NAME/g" ${CONF_FILENAME}
sed -i "s/db_username_to_replace/$DB_USERNAME/g" ${CONF_FILENAME}
sed -i "s/db_password_to_replace/$DB_PASSWORD/g" ${CONF_FILENAME}

# Run the passed in command
exec "$@"
