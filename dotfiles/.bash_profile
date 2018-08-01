BASH_ALIAS_FILE=${HOME}/.bash_alias
GIT_COMPLETION_FILE=~/.git-completion.bash
PROMPT_FILE=~/.prompt.bash

HISTTIMEFORMAT='%F %T  '
HISTSIZE=1000000

export ORCA_VERSION=1.x-latest
export ROBOT_LOCAL_DEPLOYMENTS_DIR=${HOME}/Documents/CENX/deployments

export PATH=${HOME}/Documents/bin:${HOME}/Documents/bin/platform-tools:${HOME}/Documents/git/scripts/bin:/usr/local/bin/:${PATH}
export PYTHONPATH=${HOME}/Documents/git/autotest

export PORT_NIFI=7777
export PORT_RETHINKDB=28080
export PORT_WILDFLY_DC=9990
export PORT_ZK=2181
export PORT_KAFKA=9092
export PORT_SOLR=8983
export PORT_PARKER_REPL=4081
export PORT_TERMINUS_REPL=4083
export PORT_NARANATHU_REPL=4015
export PORT_HEIMDALLR_REPL=4009
export PORT_APOLLO_REPL=4080


parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

parse_svn_branch() {
  #parse_svn_url | sed -e s#^"$(parse_svn_repository_root)"##g | awk {print " (svn::"$1")" }
  branch=$(svn info 2>/dev/null | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$')
  if [ -n "${branch}" ] ; then
    echo "(svn::${branch})"
  fi
}

if [ -f "${PROMPT_FILE}" ] ; then
    source ${PROMPT_FILE}
fi

#export PS1="\n\[$(tput bold)\]\[$(tput setaf 6)\]\t \[$(tput setaf 2)\]\[$(tput setaf 3)\]\[$(tput setaf 2)\]\w\[$(tput setaf 1)\]\$(__git_ps1) \[$(tput sgr0)\]\n\$ "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(__git_ps1)\[\033[00m\] \n\$ "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(__git_ps1)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_git_branch)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "
#export PS1="\[\e]0;\W\a\]\n\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_svn_branch)\$(parse_git_branch)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "
#export PS1="\[\e]0;\W\a\]\[$(tput setaf 6)\]\t \[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_svn_branch)\$(parse_git_branch)\[\033[00m\] \n\`if [ \$? = 0 ]; then echo \[\e[33m\]\$\[\e[0m\]; else echo \[\e[31m\]\$\[\e[0m\]; fi\` "


# References from https://stackoverflow.com/questions/16715103/bash-prompt-with-last-exit-code
function __setup_prompt() {
    local EXIT="$?"                         # This needs to be first
    local RCol='\[\e[0m\]'  # Text Reset

    # Regular                    Bold                          Underline                     High Intensity                BoldHigh Intensity             Background                High Intensity Backgrounds
    local Bla='\[\e[0;30m\]';    local BBla='\[\e[1;30m\]';    local UBla='\[\e[4;30m\]';    local IBla='\[\e[0;90m\]';    local BIBla='\[\e[1;90m\]';    local On_Bla='\e[40m';    local On_IBla='\[\e[0;100m\]';
    local Red='\[\e[31m\]';      local BRed='\[\e[1;31m\]';    local URed='\[\e[4;31m\]';    local IRed='\[\e[0;91m\]';    local BIRed='\[\e[1;91m\]';    local On_Red='\e[41m';    local On_IRed='\[\e[0;101m\]';
    local Gre='\[\e[0;32m\]';    local BGre='\[\e[1;32m\]';    local UGre='\[\e[4;32m\]';    local IGre='\[\e[0;92m\]';    local BIGre='\[\e[1;92m\]';    local On_Gre='\e[42m';    local On_IGre='\[\e[0;102m\]';
    local Yel='\[\e[0;33m\]';    local BYel='\[\e[1;33m\]';    local UYel='\[\e[4;33m\]';    local IYel='\[\e[0;93m\]';    local BIYel='\[\e[1;93m\]';    local On_Yel='\e[43m';    local On_IYel='\[\e[0;103m\]';
    local Blu='\[\e[0;34m\]';    local BBlu='\[\e[1;34m\]';    local UBlu='\[\e[4;34m\]';    local IBlu='\[\e[0;94m\]';    local BIBlu='\[\e[1;94m\]';    local On_Blu='\e[44m';    local On_IBlu='\[\e[0;104m\]';
    local Pur='\[\e[0;35m\]';    local BPur='\[\e[1;35m\]';    local UPur='\[\e[4;35m\]';    local IPur='\[\e[0;95m\]';    local BIPur='\[\e[1;95m\]';    local On_Pur='\e[45m';    local On_IPur='\[\e[0;105m\]';
    local Cya='\[\e[0;36m\]';    local BCya='\[\e[1;36m\]';    local UCya='\[\e[4;36m\]';    local ICya='\[\e[0;96m\]';    local BICya='\[\e[1;96m\]';    local On_Cya='\e[46m';    local On_ICya='\[\e[0;106m\]';
    local Whi='\[\e[0;37m\]';    local BWhi='\[\e[1;37m\]';    local UWhi='\[\e[4;37m\]';    local IWhi='\[\e[0;97m\]';    local BIWhi='\[\e[1;97m\]';    local On_Whi='\e[47m';    local On_IWhi='\[\e[0;107m\]';

    # PS1_DEFAULT="${Blu}\[$(tput setaf 6)\]\t "
    # add timestamp
    PS1="${Cya}\t ${RCol}"
    PS1+="[\!] "

    # Add previous terminal command error code to prompt if necessary
    PS1+="\`retCode=\$?; if [ \${retCode} -ne 0 ]; then echo \"${BIRed}ErrorCode:\${retCode}${RCol} \";fi\`"

    PS1+="${Gre}\u@\h "             # display username and host name
    PS1+="${Yel}\w${RCol}"          # display full pwd
    # Display version control information
    PS1+=" ${Gre}\$(parse_svn_branch)${RCol}"
    PS1+="${Gre}\$(parse_git_branch)${RCol}"

    # Display a new line
    PS1+="\n"

    # indicate if we are running as user root
    PS1+="\`if [ \"\${UID}\" = \"0\" ]; then echo \"${Yel}user:root${RCol} \"; fi\`"
    # Display a terminating prompt
    PS1+="${Yel}\$ ${RCol}"

    export PS1
}
__setup_prompt

function source_alias() {
    if [ -f ${BASH_ALIAS_FILE} ] ; then
        source ${BASH_ALIAS_FILE}
    fi
}

source_alias

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

if [ -f "${GIT_COMPLETION_FILE}" ] ; then
    source ${GIT_COMPLETION_FILE}
fi

function getAbsolutePath() {
    if [ -n "$1" ] ; then
        LOCAL_VARIABLE="${1}" && echo $(cd $(dirname "$LOCAL_VARIABLE") && pwd -P)/$(basename "$LOCAL_VARIABLE")
    fi
}

### Orca stuff
if [ $(which docker-credential-osxkeychain) ]; then
    unlink $(which docker-credential-osxkeychain)
fi

#### Git stuff

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
        git checkout -b $1
        if [ $? -eq 0 ] ; then
            git push --set-upstream origin $1
            if [ $? -ne 0 ] ; then
                git checkout ${current_branch}
                git branch -D $1
            fi
        fi
        set +x
    fi
}

