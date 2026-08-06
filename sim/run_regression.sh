#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(dirname "$SCRIPT_DIR")

iverilog -g2012 -Wall -s cpu_regression_tb \
    -o "$SCRIPT_DIR/cpu_regression.vvp" \
    "$REPO_ROOT"/rtl/*.sv \
    "$REPO_ROOT"/tb/cpu_regression_tb.sv

cd "$SCRIPT_DIR"
vvp cpu_regression.vvp
