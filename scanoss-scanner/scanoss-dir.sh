#!/usr/bin/env bash
set -euo pipefail

run() {
    local file="$1"

    for counter in {1..9}; do
        if [[ $counter -eq 1 ]]; then
            (>&2 echo "[$counter] $file")
        else
            (>&2 echo "$(tput bold)$(tput setaf 1)[$counter] $file$(tput sgr0)")
            sleep $(( $counter / 3 ))
        fi
        local result=$(scanner "$file" | sed '/^[[:digit:]]*[[:space:]]*$/d' | awk 1 RS='\r\n' ORS=)

        if jq -e . >/dev/null 2>&1 <<<"$result"; then
            echo "$result"
            return
        fi
    done
    (>&2 echo "... failed")
    cat <<EOF
{
  "$file": []
}
EOF
}

main() {
    local input="$(readlink -f "$1")"
    if [[ ! -d "$input" ]]; then
        echo "the folder input=$workdir does not exist"
        exit 1
    fi

    (cd "$input";
      find . -type f \
          -not -empty \
          -not -path '*/\.git/*' \
          -not -path '*/\.svn/*' |
          while read file; do
              run "$file"
          done  |
          jq -n '[inputs] | add'
    )
}

main "$1"
times
