#!/bin/bash
#--------------------------- Moves files from dir to another --------------------------#
#-------------------------------by tkretts(666@gmail.com)------------------------------#

set -e

function print_help() {
    cat << EOF
    Usage: $0 [-s /path -t /path]||[-h]

	This script moves files from one dir to another dir recursively
	with saving relative path

	OPTIONS:
	  -h Show this message
	  -s Source folder
	  -t Target folder
EOF
}

SOURCE=
TARGET=
COUNT=0
LOG_FILE="move_foto_`date "+%Y-%m-%d"`.log"

if [ $# = 0 ]
then
    print_help
    exit 0
fi

while getopts "hs:t:" OPTION
do
    case $OPTION in
	s)
	    SOURCE=$OPTARG;
	    ;;
	t)
	    TARGET=$OPTARG;
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

if [[ -z $SOURCE ]] || [[ -z $TARGET ]]
then
    echo "Incorrect parameter. Use $0 -h"
    print_help
    exit 1
fi

(
    cd $SOURCE
    find . -type f -print0 |
    while read -d $'\0' -r x
    do
	cp -rvf --parents "${x:2}" $TARGET/ >> $LOG_FILE
    done
)

exit
