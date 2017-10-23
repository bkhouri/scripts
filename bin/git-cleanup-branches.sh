#!/bin/bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BRANCHES_TO_KEEP="integration master"
REMOTE_NAME=origin
function printUsage() {
    echo ""
    echo "Deletes all remote branches from the repository.  "
    echo ""
    echo "${0} [OPTIONS] [ARGS]"
    echo ""
    echo "Options:"
    echo "   -h|--help           Print the help usage"
    echo "   --remote-name NAME  The remote repository name as accessed via git (Default: ${REMOTE_NAME})"
    echo "   --delete            If specified, deletes the remote branches, otherwise just does a DRYRUN"
    echo ""
    echo "Arguments"
    echo "   --  [BRANCH [ BRANCH [...]]]  Specifies the list (space delimited) of git local or remote branches to delete"
    echo "                                 (Default: ${BRANCHES_TO_KEEP})"
    echo ""
}


while [[ $# > 0 ]]
do
    case $1 in
        --remote-name)
            shift
            REMOTE_NAME=$1
            shift
            ;;
        --delete)
            shift # past argument
            DELETE=true
            ;;
        -h|--help)
            printUsage
            exit 0
            ;;
        --)
            shift
            BRANCHES_TO_KEEP="$@"
            break
            ;;
        *)
            # unknown option
            echo "Unknown Option: $1"
            printUsage
            exit 1
            ;;
    esac
done


git fetch

BRANCHES_TO_KEEP="${BRANCHES_TO_KEEP}"

echo "BRANCHES TO KEEP: ${BRANCHES_TO_KEEP}"
echo "SHOULD DELETE: ${DELETE}"

IGNORE_BRANCHES=""
for branch in ${BRANCHES_TO_KEEP}
do
    IGNORE_BRANCHES="${IGNORE_BRANCHES} | grep -v ${REMOTE_NAME}/$branch"
done
echo "TODO >>> Need to filter branches"
echo "git branch -r | grep -v HEAD ${IGNORE_BRANCHES}"
CMD=$(echo "git branch -r | grep -v HEAD ${IGNORE_BRANCHES}")
echo "CMD is: ${CMD}"

echo "Getting all branches"
ALL_BRANCHES=$(eval ${CMD})

echo "All Branches"
echo ${ALL_BRANCHES}

echo ""
echo ""
echo ""
echo ""
echo ""
echo "****** TODO:  Remote UNSETTING THE DELETE argument.  DELETE was unset until the list of all branches is working"
unset DELETE
echo ""
echo ""
echo ""
echo ""
echo ""
if [ -z ${DELETE} ] ; then
    echo "**** We are doing a dryrun"
else
    echo "**********************************************************"
    echo "*  !!!!! W A R N I N G !!!!!  !!!!! W A R N I N G !!!!!  *"
    echo "**********************************************************"
    echo ""
    echo "Remote branches will be deleted from the remote repository. This action is irrevocable.  Run in "
    echo "mode 'dryrun' first."
    echo ""
    read -p "Are you sure you want to continue? [y/N]" -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        # We don't want to proceed.. so let's exit
        echo "Exiting..."
        exit 0
    fi

fi



for branch in ${ALL_BRANCHES}
do

    CMD="git push ${REMOTE_NAME} --delete ${branch}"
    if [ -z ${DELETE} ] ; then
        CMD="echo \"would executed: ${CMD}\""
    else
        set -x
    fi

    # Run the command
    eval ${CMD}

    [ -n "$DELETE" ] && set +x

done