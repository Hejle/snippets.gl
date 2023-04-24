#!/usr/bin/env bash

set -e

# service nginx stop
# ufw allow 80
# # certbot certonly --standalone --noninteractive --agree-tos --cert-name snippets \
# #     -d snippets.gl \
# #     -d www.snippets.gl
# certbot renew
# ufw delete allow 80
# service nginx start

cd /home/vallentin

echo "Cleaning..."
rm -f /etc/nginx/sites-enabled/snippets.conf
rm -rf snippets.gl
mkdir -p snippets.gl

echo "Unpacking..."
tar -xzf snippets.tar.gz -C snippets.gl
rm -f snippets.tar.gz

cd snippets.gl

ln -sf $(pwd)/www/nginx.conf /etc/nginx/sites-enabled/snippets.conf

echo "Testing nginx.conf"
if ! nginx -t; then
    rm -f /etc/nginx/sites-enabled/snippets.conf
    exit 1
fi

echo "Restarting Nginx..."
service nginx restart
