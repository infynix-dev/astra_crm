#!/bin/bash
set -e

cd /home/frappe

# Fix permissions every start (safe & required)
chown -R frappe:frappe /home/frappe/frappe-bench || true

# If site already exists, just start
if [ -f "frappe-bench/sites/common_site_config.json" ]; then
  echo "Bench & site already exist. Starting server..."
  cd frappe-bench
  bench start
  exit 0
fi

echo "Creating new bench..."
bench init frappe-bench --version version-15 --skip-redis-config-generation

cd frappe-bench

bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

bench get-app crm --branch main

bench new-site crm.localhost \
  --force \
  --mariadb-root-password "$MYSQL_ROOT_PASSWORD" \
  --admin-password admin \
  --no-mariadb-socket

bench --site crm.localhost install-app crm
bench use crm.localhost

bench clear-cache
bench start
