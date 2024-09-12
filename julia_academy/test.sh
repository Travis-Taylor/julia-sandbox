#!/bin/bash
set -e
# Test all the julia files in this dir
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
verbose=false
target_file=

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
            echo "Verbose"
            verbose=true
            shift
            ;;
        *)
            target_file=$1
            shift
            ;;
    esac
done

# Create output &3 for intended print statements, and ignore others if not verbose
if [[ $verbose = false ]]; then
    exec 3>&1 &>/dev/null
else
    exec 3>&1
fi

if [[ -n $target_file && -f $target_file ]]; then
    echo "Running $target_file" >&3
    julia $target_file
    exit 0
fi

for julia_file in $SCRIPT_DIR/*.jl; do
    echo "Running $(basename $julia_file)" >&3
    julia $julia_file
done