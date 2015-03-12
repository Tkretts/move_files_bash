#!/usr/bin/env bash

#                  Syncronise source folder to target folder
#                  by tkretts


set -e

function print_help {
    cat << EOF
    Usage: $0 -s /path -t /path[-l /path][-r]||[-h]

	This scripts copies files from source folder to target folder
	if they are not in target folder

	OPTIONS:
	  -h Show this message

	  -s Source folder
	  -l Log folder
	  -t Target folder

	  -r Remove files from target folder, if they are not in source folder
EOF
}

SOURCE=
TARGET=
LOGGING=false
REMOVE_NOT_EXISTS=false

if [ $# = 0 ]
then
    print_help
    exit 0
fi

while getopts "hs:t:l:r" OPTION
do
    case ${OPTION} in
	s)
	    SOURCE=$OPTARG ;
	    ;;
	t)
	    TARGET=$OPTARG ;
	    ;;
	l)
	    LOGGING=true ;
	    LOG_FOLDER=$OPTARG ;
	    ;;
    r)
        REMOVE_NOT_EXISTS=true ;
        ;;
	h)
	    print_help
	    exit 0
	    ;;
	?)
	    echo "Incorrect parameters. Use $0 -h"
	    print_help
	    exit 1
	    ;;
    esac
done

# Setup logging
if ${LOGGING} ;
then
    # Create log-folder if does not exists
    if [ ! -e ${LOG_FOLDER} ] ;
    then
        echo "Log folder does not exists. Creating..."
        mkdir ${LOG_FOLDER}
        echo "OK"
    fi
    exec > "$LOG_FOLDER/tksync_`date "+%d.%m.%Y"`.log"
fi

# Check parameters
if [[ -z ${SOURCE} ]] || [[ -z ${TARGET} ]] ;
then
    echo "Incorrect parameter. Use $0 -h"
    print_help
    exit 1
fi

# Check if source and target folders are exists
if [ ! -e ${SOURCE} ] ;
then
    echo "Source folder not found. Exit."
    exit 1
fi

if [ ! -e ${TARGET} ] ;
then
    echo "Target folder not found. Exit."
    exit 1
fi

# If -r has been checked, remove deleted files from target folder
if ${REMOVE_NOT_EXISTS} ;
then
    echo "Removing non existing files..."

    cd ${TARGET}
    find . -type f -print0 |
    while read -d $'\0' -r x
    do
        if [ ! -e ${SOURCE}/"${x:2}" ] ;
        then
            rm --force --verbose ${TARGET}/"${x:2}"
        fi
    done

    echo 'Files removed.'
fi

# Copying new files to target folder
(
    echo "Copying files..."

    cd ${SOURCE}
    find . -type f -print0 |
    while read -d $'\0' -r x
    do
        if [ ! -e ${TARGET}/"${x:2}" ] ;
        then
            cp -rvf --parents "${x:2}" ${TARGET}/
        fi
    done

    echo "Success!"
)

exit
