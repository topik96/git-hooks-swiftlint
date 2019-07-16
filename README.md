# git-hooks_swiftlint

## Setup
1. Open Terminal

        brew install swiftlint 
2. Add a new "Run Script Phase" with:

        if which swiftlint >/dev/null; then
            swiftlint
        else
            echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
        fi
3. Add pre-commit file (without exetension) under .git/hooks then paste this script.

        #!/bin/bash
        #
        # hook script for swiftlint. It will triggered when you make a commit.

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
		
		#autocorrection 
		git diff --cached --name-only | grep .swift | while read filename; do
			/usr/local/bin/swiftlint autocorrect --path "$filename"
		done
	        
		exit 1
        fi
4. Run this in your terminal

        chmod +x .git/hooks/pre-commit
4. Create file .swiftlint.yml & see documentation for more rules [click](https://github.com/realm/SwiftLint)


    
