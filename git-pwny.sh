#!/bin/sh

domain=""
base_dir=""

dl() {
    wget "$domain/.git/${PWD##*.git}/$1" -O "$1"
}

sha_to_file() {
    echo "$base_dir/objects/$(sha_start "$1")/$(sha_end "$1")"
}

sha_start() {
    sed 's/^\(..\).*$/\1/' <<<"$1"
}

sha_end() {
    sed 's/^..\(.*\)$/\1/' <<<"$1"
}

dl_sha() {
    mkdir "$base_dir/objects/$(sha_start "$1")"
    dl "objects/$(sha_start "$1")/$(sha_end "$1")"
}

recursive_dl() {
    while read sha ; do
        if [ -z "$sha" ] || [ -f "$(sha_to_file $sha)" ] ; then
            continue
        fi

        dl_sha "$sha"

        git cat-file -p "$sha"        \
            | tr ' \t' '\n\n'         \
            | grep "^[0-9a-f]\{40\}$" \
            | recursive_dl
    done
}

make_base_dir() {
    mkdir "$base_dir"
    pushd .git

    mkdir -p {branches,hooks,info,objects}
    mkdir -p logs/refs/{heads,remotes/origin}
    mkdir -p refs/{heads,remotes/origin,tags}
    mkdir -p objects/{info,pack}

    dl COMMIT_EDITMSG
    dl config
    dl description
    dl FETCH_HEAD
    dl HEAD
    dl index
    dl ORIG_HEAD

    pushd hooks
    dl applypatch-msg.sample
    dl commit-msg.sample
    dl post-update.sample
    dl pre-applypatch.sample
    dl pre-commit.sample
    dl prepare-commit-msg.sample
    dl pre-push.sample
    dl pre-rebase.sample
    dl update.sample
    popd

    pushd info
    dl exclude
    popd

    popd
}

main() {
    domain="$1"

    if ! grep -q "://" <<<"$domain" ; then
        exit 1
    fi

    local dir="$(cut -d '/' -f 3 <<<"$domain")"
    mkdir "$dir"
    cd "$dir"

    base_dir="$(pwd)/.git/"

    make_base_dir
    pushd "$base_dir"

    local head_file="$(cat HEAD | cut -d ' ' -f 2)"
    dl "$head_file"

    recursive_dl <<< "$(cat "$head_file")"
    popd

    git checkout .
}
main "$@"
