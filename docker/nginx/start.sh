#!/bin/sh

set -ex

rm -fr /var/app.root
cp -ar /var/app /var/app.root

(
  cd /var/app.root
  sed -i -e "s%http://change.me.on.deploy%${USHAHIDI_URL}%" js/bundle.js
  sed -i -e "s%http://change.me.on.deploy%${USHAHIDI_URL}%" js/bundle.js.map
)

cat > /etc/nginx/conf.d/upstream.conf << EOF
upstream api_backend {
	server ${API_PORT_9000_TCP_ADDR}:${API_PORT_9000_TCP_PORT};
}
EOF

exec /usr/sbin/nginx -g 'daemon off;'