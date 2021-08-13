#!/usr/bin/env bash

runAll() {
    logfile=/outputs/log

    echo "#############################################################" > "$logfile"
    echo "## $(date): $@" > "$logfile"
    echo "#############################################################" > "$logfile"
    exec &> >(tee -a "$logfile")

    OCTRC_INPUT=/inputs rake --rakefile /octrc.Rakefile --directory /outputs $@
}

runAll $@
