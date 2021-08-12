#!/usr/bin/env bash
logfile=/outputs/log

echo "#############################################################" > "$logfile"
echo "## $(date): $@" > "$logfile"
echo "#############################################################" > "$logfile"
exec &> >(tee -a "$logfile")

rake
