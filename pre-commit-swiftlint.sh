#!/bin/bash
#
# hook script for swiftlint. It will triggered when you make a commit.
#
# If you want to use, type commands in your console.
# $ ln -s ../../pre-commit-swiftlint.sh .git/hooks/pre-commit
# $ chmod +x .git/hooks/pre-commit

LINT=$(which swiftlint)

if [[ -e "${LINT}" ]]; then
	echo "SwiftLint Start..."
else
	echo "SwiftLint does not exist, download from https://github.com/realm/SwiftLint"
	exit 1
fi

RESULT=$($LINT lint --quiet)

if [ "$RESULT" == '' ]; then
	printf "\e[32mSwiftLint Finished.\e[39m\n"
else
	echo ""
	printf "\e[41mSwiftLint Failed.\e[49m Please check below:\n"

	while read -r line; do

		FILEPATH=$(echo $line | cut -d : -f 1)
		L=$(echo $line | cut -d : -f 2)
		C=$(echo $line | cut -d : -f 3)
		TYPE=$(echo $line | cut -d : -f 4 | cut -c 2-)
		MESSAGE=$(echo $line | cut -d : -f 5 | cut -c 2-)
		DESCRIPTION=$(echo $line | cut -d : -f 6 | cut -c 2-)
		if [ "$TYPE" == 'error' ]; then
			printf "\n  \e[31m$TYPE\e[39m\n"
		else
			printf "\n  \e[33m$TYPE\e[39m\n"
		fi
		printf "    \e[90m$FILEPATH:$L:$C\e[39m\n"
		printf "    $MESSAGE - $DESCRIPTION\n"
	done <<< "$RESULT"

	printf "\nCOMMIT ABORTED. Please fix them before commiting.\n"

	exit 1
fi
