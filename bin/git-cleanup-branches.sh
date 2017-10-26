# Copyright Year 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    echo "   --  [BRANCH [ BRANCH [...]]]  Specifies the list (space delimited) of git remote branches to keep"
    echo "                                 on the remote repository "
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
            BRANCHES_TO_KEEP="${BRANCHES_TO_KEEP} $@"
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

IGNORE_BRANCHES=""
for branch in ${BRANCHES_TO_KEEP}
do
    IGNORE_BRANCHES="${IGNORE_BRANCHES} | grep -v ${REMOTE_NAME}/$branch"
done

echo "Getting all branches"
CMD=$(echo "git branch -r | grep -v HEAD ${IGNORE_BRANCHES}")
ALL_BRANCHES=$(eval ${CMD})
echo Branches: ${ALL_BRANCHES}

echo ""
echo ""
if [ -z ${DELETE} ] ; then
    read -p "**** We are doing a dryrun.  Press any key to continue." -n 1 -r
    echo ""
    echo ""
    # echo "**** We are doing a dryrun"
else
    echo "**********************************************************"
    echo "*  !!!!! W A R N I N G !!!!!  !!!!! W A R N I N G !!!!!  *"
    echo "**********************************************************"
    echo ""
    echo "The following remote branches will be removed from the remote repository"
    for branch in ${ALL_BRANCHES}
    do
        echo "  - ${branch}"
    done
    echo "The remote branches listed above will be deleted from the remote repository.  "
    echo "Run in mode 'dryrun' first."
    echo ""
    read -p "This action is irrevocable.  Are you sure you want to continue? [y/N]" -n 1 -r
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
