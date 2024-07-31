#!/usr/bin/env bash
set -e
exec > >(logger -t autoreboot) 2>&1
echo 'Automatically rebooting from cron job'
exec /sbin/reboot
