#!/usr/bin/env bash
logfile=/outputs/log

echo "#############################################################" > "$logfile"
echo "## $(date): $@" > "$logfile"
echo "#############################################################" > "$logfile"
exec &> >(tee -a "$logfile")

OCTRC_INPUTS=/inputs rake --rakefile /octrc.Rakefile --directory /outputs
