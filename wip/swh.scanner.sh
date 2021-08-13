#!/usr/bin/env bash
set -e

pipEnvDir="$HOME/.license-compliance-toolbox-pip-env"
helpMsg() {
    cat<<EOF
usage:
  $0 --help
EOF
}

activateSWH() {
    pushd "$pipEnvDir"
    source bin/activate
    popd
}

setup() {
    if [[ ! -d "$pipEnvDir" ]]; then
        python3 -m venv $pipEnvDir
        activateSWH
    else
        activateSWH
    fi
    pip install  swh.scanner

}


setup

# case $1 in
#     "-d") shift; runSWHOnDockerfile "$@";;
#     "-i") shift; runSWHOnImage "$@";;
#     "--help") helpMsg ;;
#     *) shift;
#        if [[ -f "$1" ]]; then
#            runSWHOnDockerfile "$@"
#        elif [[ -d "$1" ]]; then
#            runSWHRecursively "$1"
#        else
#            tern "$@"
#        fi
#        ;;
# esac
bash
times
