#!/bin/bash
set -e

echo "Starting Frappe bootstrap..."

# 1️⃣ Fix permissions FIRST (this is critical)
chown -R frappe:frappe /home/frappe || true

# 2️⃣ Switch to frappe user for bench commands
exec su frappe -c '
cd /home/frappe

# If bench already exists, just start
if [ -d "frappe-bench" ] && [ -f "frappe-bench/sites/common_site_config.json" ]; then
  echo "Bench already exists. Starting..."
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
'
