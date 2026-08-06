#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(dirname "$SCRIPT_DIR")

iverilog -g2012 -Wall -s fibonacci_tb \
    -o "$SCRIPT_DIR/fibonacci.vvp" \
    "$REPO_ROOT"/rtl/*.sv \
    "$REPO_ROOT"/tb/fibonacci_tb.sv

cd "$SCRIPT_DIR"
vvp fibonacci.vvp
