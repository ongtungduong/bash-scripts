#!/bin/bash

# Set variables
URL=""       # Change me
FOLDER=""    # Change me

# Remove query string from URL and get filename
url_without_query_string="${URL%%\?*}"
filename="${url_without_query_string##*/}"

# Download file with wget
wget $URL -O $FOLDER/$filename
