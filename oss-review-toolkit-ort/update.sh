#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq
# Copyright 2021 Maximilian Huber <oss@maximilian-huber.de>
# SPDX-License-Identifier: MIT

updateRefAndJson() {
    set -x

    local repo="oss-review-toolkit/ort"
    local repoName=$(basename "$repo")
    local repoUser=$(dirname "$repo")
    local branch=${1:-master}
    local outRev=ort.rev
    local outJson=ort.json

    local rev="$(curl -s "https://api.github.com/repos/$repo/commits/${branch}" | jq -r '.sha')"
    if [[ "$rev" != "null" ]]; then
        if ! grep -q $rev "$outRev" 2>/dev/null; then
            echo $rev > "$outRev"

            local url="https://github.com/$repo"
            local tarball="https://github.com/$repo/archive/${rev}.tar.gz"
            prefetchOutput=$(nix-prefetch-url --unpack --print-path --type sha256 $tarball)
            local hash=$(echo "$prefetchOutput" | head -1)
            local path=$(echo "$prefetchOutput" | tail -1)
            echo '{"url":"'$tarball'","rev": "'$rev'","sha256":"'$hash'","path":"'$path'","ref": "'$branch'", "url": "'$url'", "owner": "'$repoUser'", "repo": "'$repoName'"}' > "./$outJson"
        fi
    fi
}

updateRefAndJson "$@"
