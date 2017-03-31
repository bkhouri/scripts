BASH_ALIAS_FILE=~/.bash_alias
GIT_COMPLETION_FILE=~/.git-completion.bash

export PATH=${HOME}/bin:${HOME}/Documents/CENX/git/dev-env/bin:/usr/local/bin/:${PATH}
export PYTHONPATH=${HOME}/Documents/CENX/git/autotest

export PORT_ZK=2181
export PORT_KAFKA=9092
export PORT_SOLR=8983
export PORT_PARKER_REPL=4081
export PORT_TERMINUS_REPL=4083
export PORT_NARANATHU_REPL=4015
export PORT_HEIMDALLR_REPL=4009
export PORT_APOLLO_REPL=4080

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}

parse_svn_branch() {
  #parse_svn_url | sed -e s#^"$(parse_svn_repository_root)"##g | awk {print " (svn::"$1")" }
  branch=$(svn info 2>/dev/null | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$')
  if [ -n "${branch}" ] ; then
    echo "(svn::${branch})"
  fi
}

#export PS1="\n\[$(tput bold)\]\[$(tput setaf 6)\]\t \[$(tput setaf 2)\]\[$(tput setaf 3)\]\[$(tput setaf 2)\]\w\[$(tput setaf 1)\]\$(__git_ps1) \[$(tput sgr0)\]\n\$ "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(__git_ps1)\[\033[00m\] \n\$ "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(__git_ps1)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_git_branch)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "
export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_svn_branch)\$(parse_git_branch)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "


#export PGHOST=localhost;
export HOMEBREW_GITHUB_API_TOKEN=a28bca4c9230a74d90270ca8fb305ac8dd993c50
export CORTX_HOME=~/Documents/CENX/git/devops/deployments/dev-small


function source_alias() {
    if [ -f ${BASH_ALIAS_FILE} ] ; then
        source ${BASH_ALIAS_FILE}
    fi
}

source_alias

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

if [ -f ${GIT_COMPLETION_FILE} ] ; then
    source ${GIT_COMPLETION_FILE}
fi


function getAbsolutePath() {
    if [ -n "$1" ] ; then
        LOCAL_VARIABLE="${1}" && echo $(cd $(dirname "$LOCAL_VARIABLE") && pwd -P)/$(basename "$LOCAL_VARIABLE")
    fi
}


function ctx_home() {
    if [ -n "$1" ] ; then
        export CORTX_HOME=$(getAbsolutePath ${1});
    else
        export CORTX_HOME=${PWD};
    fi
    echo "env CORTX_HOME set to ${CORTX_HOME}"
}

function crtx_home() {
   ctx_home $@
}
function dminit() {
    echo "Initiallizing docker machine name $1"
    eval $(docker-machine env $1)
    export DOCKER_MACHINE_IP="$(docker-machine ip $DOCKER_MACHINE_NAME)"
}


function dmstart () {
    dmName=$1
    if docker-machine start "$@"
    then
        dminit ${dmName}; # sets DOCKER_MACHINE_NAME et al
    fi
}

function dmstop () {
  docker-machine stop "$DOCKER_MACHINE_NAME"
}




## Git Helpers...

function gc() {
    if [ -z "$1" ] ; then
        echo "*******************************************"
        echo "*   !!! WARNING !!!  Repo not cloned      *"
        echo "*******************************************"
        echo ""
        echo "Silly me!!! I need to specify a parameter, to repo to clone (without cenx-cf/)"
    else
       set -x
       git clone git@bitbucket.org:cenx-cf/$@
       set +x
    fi
}


function git_create_branch() {
    if [ -z "$1" ] ; then
        echo "*******************************************"
        echo "*   !!! WARNING !!!  Branch not created   *"
        echo "*******************************************"
        echo ""
        echo "Silly me!!! I need to specify a parameter, the branch.."
    else
        current_branch=$(parse_git_branch)
        set -x
        git co -b $1
        if [ $? -eq 0 ] ; then
            git push --set-upstream origin $1
            if [ $? -ne 0 ] ; then
                git co ${current_branch}
                git branch -D $1
            fi
        fi
        set +x
    fi
}
