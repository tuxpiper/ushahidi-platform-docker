#!/bin/sh

cat > /var/www/.env <<EOF
DB_HOST=${MYSQL_PORT_3306_TCP_ADDR}
DB_NAME=${MYSQL_ENV_MYSQL_DATABASE}
DB_PASS=${MYSQL_ENV_MYSQL_PASSWORD}
DB_TYPE=MySQLi
DB_USER=${MYSQL_ENV_MYSQL_USER}
EOF

# Wait until MySQL is up
echo -n "Checking MySQL "
k=1; while [ "$k" -lt "60" ]; do
  if nc -w 1 ${MYSQL_PORT_3306_TCP_ADDR} 3306 > /dev/null < /dev/null ; then
    break;
  fi
  echo "."
  sleep 1;
  k=$((k + 1))
done
sleep 5;
echo

( cd /var/www && ./bin/update --no-interaction )
