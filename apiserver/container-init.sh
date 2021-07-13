#!/bin/sh
PORT=${PORT:-80}
exec bundle exec puma -e production -p "$PORT"
