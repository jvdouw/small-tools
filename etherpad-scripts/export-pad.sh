#!/bin/bash

################
# Dependencies #
################
# - pandoc
# - jq

#################
# Configuration #
#################

# Make sure dates are Dutch
export LC_TIME=nl_NL.UTF-8
# Get API key, in this use case stored on the same machine as this script runs,
# namely my Raspberry Pi, so I can retrieve it directly from the Etherpad
# installation.
apikey=$(cat ~/git/etherpad-lite/APIKEY.txt)
# Configure the name of the Etherpad pad
padName='babypaklijst'
# Give the name for the files you're producing
fileNameBase=$padName
# Directory to export to
exportDir='/var/www/html/'
# Optional (may both be left empty) set the localized text you want to prepend
# and append the modification date with, that will be added at the bottom of
# the export. Make sure to add spaces as the date itself does not have spaces
# around it.
beforeModDateText="Versie van "
afterModDateText=" (origineel van 22 april 2019)"

#############
# Set it up #
#############

# Make sure it's a long (weird) name that has a very low chance of already
# being used for something else
tempDir="/tmp/etherpad-$padName-$fileNameBase-export/"
# Make temporary directory in /tmp for storing preliminary results
if [[ ! -d $tempDir ]]; then
  mkdir $tempDir
fi

##################################
# Get the data and do the export #
##################################

# Retrieve data from localhost through Etherpad API
curl http://localhost:9001/api/1/getText?padID=$padName\&apikey=$apikey > $tempDir$fileNameBase.json 2>/dev/null

# Get text from JSON result, un-escape newlines and tabs, remove quotes
jq '.data.text' $tempDir$fileNameBase.json | sed -r 's/(^"|"$)//g'| sed 's/\\n/\n/g' | sed 's/\\t/\t/g' > $tempDir$fileNameBase.md

# Add two number signs at the beginning of the text, (in HTML to be <h2>)
# otherwise pandoc doesn't process correctly, and it's good to have a title
# anyway. Also, add a date to the end of the file, including surrounding text
# defined in the configuration section.
sed -r '1s/^.*/##&/' $tempDir$fileNameBase.md > $tempDir$fileNameBase-2.md
eindtekst='$a\
\
_'$beforeModDateText$(date "+%A %d %B %Y om %H:%Mu")$afterModDateText'_'
sed -r "$eindtekst" $tempDir$fileNameBase-2.md > $tempDir$fileNameBase-3.md

# Also, remove indentation of upper-most <ul> items (with one tab in the
# beginning and no further tabs)
sed -r 's/\t([^t]*)/\1/g' $tempDir$fileNameBase-3.md > $tempDir$fileNameBase-4.md

# Convert to html and put in public dir
pandoc -f markdown $tempDir$fileNameBase-4.md > $exportDir$fileNameBase-bare.html

# Also export to docx
pandoc -f markdown -t docx $tempDir$fileNameBase-4.md -o $exportDir$fileNameBase.docx

