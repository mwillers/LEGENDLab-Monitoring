#!/usr/bin/bash
# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OUTPUT_FILE="$(date +%Y_%m_%d).csv"
OUTPUT_FILE="${SCRIPT_DIR}/log/${OUTPUT_FILE}"

JULIA="/home/legend/software/julia-1.9.0/bin/julia"
PYTHON="/home/legend/software/conda/bin/python"

TIMEOUT_DURATION="15s"

echo "Running script from: $SCRIPT_DIR"
echo "Saving to: $OUTPUT_FILE"

command="${JULIA} ${SCRIPT_DIR}/Monitor.jl"

output=$(timeout $TIMEOUT_DURATION $command)
echo "$output"
echo "$output" >> $OUTPUT_FILE

(timeout $TIMEOUT_DURATION $PYTHON ${SCRIPT_DIR}/Plot.py)
(timeout $TIMEOUT_DURATION $PYTHON ${SCRIPT_DIR}/Plot24.py)

chown -R legend:legend $SCRIPT_DIR