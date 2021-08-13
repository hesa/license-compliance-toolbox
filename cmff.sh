#!/usr/bin/env bash
set -euo pipefail

collectMetadataForFiles() {
    local input="$1"; shift
    local output="$(readlink -f "$1")"; shift

    mkdir -p "$output"
    cd "$input"

    find . -type f -print0 |
        while IFS= read -r -d "" file; do
            fileDir="$(realpath -m "$output/$file")"
            (set +e
             mkdir -p "$fileDir"
             echo "$file" >> "$output/_files"
             md5sum "$file" > "$fileDir/md5sum"
             sha1sum "$file" > "$fileDir/sha1sum"
             sha256sum "$file" > "$fileDir/sha256sum"
             sha512sum "$file" > "$fileDir/sha512sum"
             file "$file" > "$fileDir/file"
             wc "$file" > "$fileDir/wc"
             du -h "$file" > "$fileDir/du"
             exiftool "$file" > "$fileDir/exiftool"
             simhash "$file" > "$fileDir/simhash" || rm "$fileDir/simhash"
             true
            )
        done
    find . -type d -print0 |
        while IFS= read -r -d "" dir; do
            dirDir="$output/$dir"
            (set +e
             mkdir -p "$dirDir"
             ls -alF $dir > "$dirDir/ls"
             # TODO: cloc every dir?
            )
        done
}

collectMetadataForFiles "$1" "$2"
