#!/bin/bash
#***************************************************************************************#
# This script takes all files with a certain file extension and changes the namin       #
# scheme using awk.									#
#											#
# You can either give the extension as a parameter like "rename_scheme.sh flac" or 	#
# leave the parameters blank and enter it as input.					#
#***************************************************************************************#

# Get extension of files that shall be renamed
if [ -z $1 ]; then
	read -p "Enter file extension of files you want to rename (e.g. flac, mp3, pdf): " ext
else
	ext=$1
fi

# Get seperator and new naming scheme
read -p "Enter Seperator (e.g. -,.,SPACE): " sep
read -p 'Enter new naming scheme as regular expression for awk (e.g. $1" - "$3): ' scheme

# Print renaming of files
for file in *.$ext; do
	new_name=$(awk -F $sep '{print '"$scheme"'}' <<<"$file")
	echo "$file ---> $new_name"
done

# Rename files if ok
read -p "Want to rename files as listed above? [y/N]: " run

if [ "$run" == "y" ]; then
	for file in *.$ext; do
		new_name=$(awk -F $sep '{print '"$scheme"'}' <<<"$file")
		mv "$file" "$new_name"
	done
	echo "Done."
else
	echo "Aborted."
fi
