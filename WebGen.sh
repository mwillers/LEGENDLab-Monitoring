#!/bin/bash
# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Directory containing images relative to the script
IMAGE_DIRECTORY="$SCRIPT_DIR/html/img"

# Path to the index.html file relative to the script
HTML_FILE="$SCRIPT_DIR/html/index.html"

# Name of the default image
DEFAULT_IMAGE="latest.png"

SERVICE="LEGENDLab-Monitoring.timer"
STATUS=$(systemctl is-active "$SERVICE")

# Start writing to index.html
cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html>
<head>
    <title>LEGENDLab Monitoring</title>
    <meta http-equiv="refresh" content="60">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            background-color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        .container {
            text-align: center;
            margin-bottom: 10px;
        }
        #imageDisplay {
            max-width: 90%;
            height: auto;
        }
        select, button {
            margin: 5px;
        }
        .alert {
            font-family: system-ui, sans-serif;
            font-size: 1rem;
            font-weight: 400;
            line-height: 1.5;
            position: relative;
            padding: 0.5rem 0.5rem;
            margin-bottom: 0.5rem;
            color: #ffffff;
            background-color: transparent;
            border: 1px solid transparent;
            border-radius: 0.25rem;
        }
        .alert-success {
            color: #0a3622;
            background-color: #d1e7dd;
            border-color: #a3cfbb;
        }
        .alert-warning {
            color: #664d03;
            background-color: #fff3cd;
            border-color: #ffe69c;
        }
        .alert-danger {
            color: #58151c;
            background-color: #f8d7da;
            border-color: #f1aeb5;
        }
        .alert-dark {
            color: #495057;
            background-color: #495057;
            border-color: #adb5bd;
        }
    </style>
</head>
<body>
<div class="container">
<select id='imageDropdown' onchange='showImage(this.value)'>
EOF

# Loop through all images in the sub-folder
for IMAGE in "$IMAGE_DIRECTORY"/*
do
    if [[ -f $IMAGE ]]; then
        FILENAME=$(basename "$IMAGE")
        SELECTED=""
        if [ "$FILENAME" == "$DEFAULT_IMAGE" ]; then
            SELECTED="selected"
        fi
        echo "<option value='$FILENAME' $SELECTED>$FILENAME</option>" >> "$HTML_FILE"
    fi
done

# Finalize the HTML content with the default image set
cat <<EOF >> "$HTML_FILE"
</select>
<button onclick='resetImage()'>Reset</button>
EOF

case $STATUS in
    active)
        echo "<div class='alert alert-success'>The monitoring service is running.</div>" >> "$HTML_FILE"
        ;;
    inactive)
        echo "<div class='alert alert-warning'>The monitoring service is stopped.</div>" >> "$HTML_FILE"
        ;;
    failed)
        echo "<div class='alert alert-danger'>The monitoring service has failed.</div>" >> "$HTML_FILE"
        ;;
    *)
        echo "<div class='alert alert-dark'>The monitoring service is in an unknown state.</div>" >> "$HTML_FILE"
        ;;
esac

cat <<EOF >> "$HTML_FILE"
</div>
<img id='imageDisplay' src='img/$DEFAULT_IMAGE' alt='Selected Image' class='center'>
<script>
function showImage(imageFile) {
    document.getElementById('imageDisplay').src = 'img/' + imageFile;
}
function resetImage() {
    var dropdown = document.getElementById('imageDropdown');
    dropdown.value = '$DEFAULT_IMAGE';
    showImage(dropdown.value);
}
</script>
</body></html>
EOF
