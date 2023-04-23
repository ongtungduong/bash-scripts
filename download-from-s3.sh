#!/bin/bash

# Set variables
FILE_PATH=""    # Change me
URL=""          # Change me

# Remove query string from URL and get filename
url_without_query_string="${URL%%\?*}"
filename="${url_without_query_string##*/}"

# Download file with wget
wget $URL -O $FILE_PATH/$filename