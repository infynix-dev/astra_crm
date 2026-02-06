#!/bin/bash
set -e

echo "Starting Frappe CRM setup..."

cd /home/frappe

if [ -d "frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, starting..."
    cd frappe-bench
    bench start
    exit 0
fi

echo "Creating new bench..."
bench init frappe-bench --version version-15 --skip-redis-config-generation

cd frappe-bench

echo "Configuring database & redis..."
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

# Remove redis & watch (handled by docker)
sed -i '/redis/d' Procfile
sed -i '/watch/d' Procfile

echo "Fetching CRM app..."
bench get-app crm --branch main

echo "Creating site..."
bench new-site crm.localhost \
  --force \
  --mariadb-root-password "$MYSQL_ROOT_PASSWORD" \
  --admin-password admin \
  --no-mariadb-socket

echo "Installing CRM app..."
bench --site crm.localhost install-app crm

echo "Applying dev configs..."
bench --site crm.localhost set-config developer_mode 1
bench --site crm.localhost set-config mute_emails 1
bench --site crm.localhost set-config server_script_enabled 1

bench use crm.localhost
bench clear-cache

echo "Starting bench..."
bench start
