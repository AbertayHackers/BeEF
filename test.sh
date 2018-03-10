#!/usr/bin/env bash
# BeEF/test.sh

# test.sh
# 	Find shell scripts then run shellcheck 
#	Find python files then run pylint
# 	Adapted from jessfraz/dotfiles/bin/test.sh
# 	https://github.com/jessfraz/dotfiles/blob/master/test.sh

set -euo pipefail

ERRORS=()

FAIL="\\033[1;31mFAIL\\033[0m"
PASS="\\033[1;32mPASS\\033[0m"

for f in $(find . -type f -not -iwholename '*.git*' -not -iwholename '*venv*' | sort -u); do
	# Find all regular files in source directory, ignore git files and filter out duplicates 
	
	if file "${f}" | grep --quiet "shell" ; then
		# Find shell files
		{
			shellcheck "${f}" && echo -e "[${PASS}] Sucessfully linted ${f}"
			# Run shellcheck 
		} || {
			ERRORS+=("${f}")
			# Store shellcheck errors
		}

	# elif file "${f}" | grep --quiet "Python" ; then
	# 	# Find python files
	# 	{
	# 		pylint "${f}" && echo -e "[${PASS}] Sucessfully linted ${f}"
	# 		# Run pylint 
	# 	} || {
	# 		ERRORS+=("${f}")
	# 		# Store pylint errors
	# 	}
	fi
done


if [ ${#ERRORS[@]} -eq 0 ]; then
	# If ERRORS empty then 
	echo -e "[${PASS}] No errors, hooray"
else
	# If errors print the names of files which failed
	echo -e "[${FAIL}] These files failed linting: ${ERRORS[*]}"
	exit 1
fi
