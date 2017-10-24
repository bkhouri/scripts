#!/bin/bash

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


# https://jenkins.io/doc/book/pipeline/development/#linter
JENKINS_URL="http://jenkins.cenx.localnet:10080"
JENKINS_FILE="Jenkinsfile"


BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function printUsage() {
    echo ""
    echo "Validates the Jenkinsfile"
    echo ""
    echo "${0} [OPTIONS] [ARGS]"
    echo ""
    echo "Options:"
    echo "   -h|--help              Print the help usage"
    echo "   --url URL              The Jenkins URL (Default: ${JENKINS_URL})"
    echo "   --jekinsfile FILENAME  The Jenkinsfile to validate (Default: ${JENKINS_FILE})"
    echo ""
}

while [[ $# > 0 ]]
do
    case $1 in
        --url)
            shift
            JENKINS_URL=$1
            shift
            ;;
        --jenkinsfile)
            shift # past argument
            JENKINS_FILE=true
            shift
            ;;
        -h|--help)
            printUsage
            exit 0
            ;;
        *)
            # unknown option
            echo "Unknown Option: $1"
            printUsage
            exit 1
            ;;
    esac
done


if [ ! -f "${JENKINS_FILE}" ] ; then
    echo "The provide Jenkinsfile (${JENKINS_FILE}) does not exist.  Exiting..."
    exit 0
fi

echo "Requesting Jenkins crumb..."
set -x
JENKINS_CRUMB=`curl --silent "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"`
curl -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<$JENKINS_FILE" $JENKINS_URL/pipeline-model-converter/validate
set +x
