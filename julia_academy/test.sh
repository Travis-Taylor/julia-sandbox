#!/bin/bash
set -e
# Test all the julia files in this dir
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
verbose=false

usage() {
    printf "Usage:\n\t$0 [filename] [-v]\n"
    echo "If filename unspecified, runs all .jl files in this directory"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            usage
            ;;
        -v)
            verbose=true
            shift
            ;;
        *)
            break;
            ;;
    esac
done

# Create output &3 for intended print statements, and ignore others if not verbose
if [[ $verbose = false ]]; then
    exec 3>&1 &>/dev/null
else
    exec 3>&1
fi

if [[ -n $1 ]]; then
    if [[ $1 == "-h" ]]; then
        usage
    fi
    if [[ -f $1 ]]; then
        echo "Running $1" >&3
        julia $1
        exit 0
    fi
fi

for julia_file in $SCRIPT_DIR/*.jl; do
    echo "Running $(basename $julia_file)" >&3
    # Quiet stdout, but emit stderr
    julia $julia_file
done