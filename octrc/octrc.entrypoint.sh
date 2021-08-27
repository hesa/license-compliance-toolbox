#!/usr/bin/env bash

runAll() {
    logfile=/outputs/log

    echo "#############################################################" > "$logfile"
    echo "## $(date): $@" > "$logfile"
    echo "#############################################################" > "$logfile"
    exec &> >(tee -a "$logfile")

    OCTRC_INPUT=/inputs rake --rakefile /octrc.Rakefile --directory /outputs $@
}

if [[ "$1" == "--help" ]]; then
    shift
    OCTRC_INPUT=/inputs rake --rakefile /octrc.Rakefile --directory /outputs -T
    exit 0
fi

export GOPATH=$HOME/go # https://github.com/oss-review-toolkit/ort/issues/4407

runAll $@
