## Needed for Avengers
ulimit -S -n 1024

#start momentics
#start_momentics(){
#    source /Volumes/BlackBerry\ Native\ SDK/Momentics.app/bbndk-env_127_0_1_6317.sh
#    /Applications/Momentics.app/qde
#}

set_java_version() {
  if [ -n "$1" ] ; then
     export JAVA_HOME=$(/usr/libexec/java_home -v $1)
     echo "JAVA_HOME is set to $JAVA_HOME"
  else
     echo "You need to provide a version.  (e.g.: 1.7 )"
  fi
}
set_java_version 1.7

set_python_path() {
    #export PYTHONPATH=$ROBOT_HOME:$TEST_PROJECTS_SRC:$TEST_PROJECTS:$PYTHONPATH 
    export VFS_PYTHONPATH=$PYTHONPATH
    echo "PYTHONPATH is set to $PYTHONPATH"
}
export TEST_PROJECTS=/Users/bkhouri/Documents/git/test_projects
export TEST_PROJECTS_SRC=/Users/bkhouri/Documents/git/test_projects_src
export ROBOT_HOME=/Users/bkhouri/Documents/git/pim-all/robot
export ROBOT_PIMCORE=/Users/bkhouri/Documents/git/pim-all/services/pimcore/robot
set_python_path

export AVEN_TOOLS=~/Documents/git/ezy_avengers_tools/scripts
#export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_25.jdk/Contents/Home
#export QCONF_OVERRIDE=/Users/bkhouri/qconf_overrides/trunk.mk

### The followin is the contents of the file references in QCONF_OVERRIDE.  it's added here for the SMARTDeploy tool
#export USE_INSTALL_ROOT=1
#export INSTALL_ROOT_nto=/Users/bkhouri/Documents/git/pim-all/output_stage/nto

#### Avengers stuff
export ANDROID_HOME=/Users/bkhouri/development/android/sdk
export ANDROID_NDK_HOME=/Users/bkhouri/development/android/ndk

export NDK_PATH=${ANDROID_NDK_HOME}
export SDK_PATH=${ANDROID_HOME}

export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:~/bin:~/bin/qnxtools/bin:/opt/local/bin:/opt/subversion/bin:/usr/local/bin:/usr/local/git/bin:/usr/local/mysql/bin/:$AVEN_TOOLS:${SDK_PATH}/platform-tools:${SDK_PATH}/tools:${NDK_PATH}:${PATH}
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${SDK_PATH}/platform-tools:${SDK_PATH}/tools:${NDK_PATH}:${PATH}"
#export PATH=~/bin:~/bin/qnxtools/bin:/opt/subversion/bin:/usr/local/bin:/usr/local/git/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:$AVEN_TOOLS:$PATH
# Custom alias
if [ -f ~/.bash_alias ] ; then
    source ~/.bash_alias
fi

# Git branch in prompt.
parse_git_branch1() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function we_are_in_git_work_tree {
    git rev-parse --is-inside-work-tree &> /dev/null
}

function parse_git_branch() {
    if we_are_in_git_work_tree
    then
    local BR=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD 2> /dev/null)
    if [ "$BR" == HEAD ]
    then
        local NM=$(git name-rev --name-only HEAD 2> /dev/null)
        if [ "$NM" != undefined ]
        then echo -n "(@$NM)"
        else git rev-parse --short HEAD 2> /dev/null
        fi
    else
        echo -n "($BR)"
    fi
    fi
}

### Git auto-completion
source ~/.git-completion.bash
source ~/.git-prompt.sh

#export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
export PS1="\[\e]0;\W\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_git_branch1)\[\033[00m\] \n\$ "
#export PS1="\[\033[0m\]\[\033[32m\]\u@\h \[\033[33m\]\w $(parse_git_branch)\[\033[0m\]\n$ "
#export PS1="\[\e]0;\W\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(__git_ps1)\[\033[00m\] \n\$ "


#export LESS='-R -P?f%f - .?ltLine?lbs. %lt?lb-%lb.?L of %L. (%pB\%):?pt%pt\%:?btByte %bt:-...'

function device_ip() {
    #ifconfig en19 inet | sed '/inet/!d' | awk '{print $2}' | awk -F. '{print $1 "." $2 "." $3 "." ($4) - 1}'
    #local ip=$(ifconfig | awk '/inet /{inet=$2}  /media.*UTP/{print inet}' | awk -F. '{print $1 "." $2 "." $3 "." ($4) - 1}')
    local ip=$(ifconfig | grep inet | grep -v inet6 | sed -r 's/.*inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) .*/\1/' | grep 169 | awk -F. '{print $1 "." $2 "." $3 "." ($4) - 1}')
    if [[ $ip = *$'\n'* ]]; then
        echo Multiple devices detected: $ip > /dev/stderr
    elif [ -z $ip ]; then
        echo "No device detected" > /dev/stderr
    else
        echo $ip
    fi
}


function bbtelnet() {
    local DEVICE=$(device_ip)
    if [ -z $DEVICE ]; then echo "Cannot telnet to device"; return; fi
    telnet $DEVICE
}

function bbssh() {
    local DEVICE=$(device_ip)
    if [ -z $DEVICE ]; then echo "Cannot ssh to device"; return; fi
    ssh root@$DEVICE $@
}


function bbpswdfree() {
    local DEVICE=$(device_ip)
    if [ -z $DEVICE ]; then echo "Cannot make device password free"; return; fi
    echo "Easy login: making $DEVICE password free" ;
    PUB_KEY=$(<~/.ssh/id_rsa.pub)
    PUB_KEY=$(<~/.ssh/id_rsa.pub)
    cmd="if [ ! -e /root/.ssh ] ; then mkdir /root/.ssh ; fi; if ! grep -Fxq \"$PUB_KEY\" /root/.ssh/authorized_keys 2>/dev/null ; then echo $PUB_KEY >> /root/.ssh/authorized_keys && touch /root/.ssh/EASY_LOGIN ; fi"
    ssh root@$DEVICE $cmd
}

function bbpswdnotfree() {
    local DEVICE=$(device_ip)
    if [ -z $DEVICE ]; then echo "Cannot restore password on device"; return; fi
    echo "Easy login: making $DEVICE NOT password free" ;
    PUB_KEY=$(<~/.ssh/id_rsa.pub)
    cmd="if [ -f /root/.ssh/EASY_LOGIN ] && grep -Fxq \"$PUB_KEY\" /root/.ssh/authorized_keys 2>/dev/null ; then sed -i.bak -e \"\|$PUB_KEY|d\" /root/.ssh/authorized_keys ; rm -f /root/.ssh/EASY_LOGIN ; fi"
    ssh root@$DEVICE $cmd
}

########################################
# Where am I?
# Reference: http://hocuspokus.net/2009/07/add-git-and-svn-branch-to-bash-prompt/

get_svn_url() {
  svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}
get_svn_repo_root() {
  svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}
get_svn_branch() {
  get_svn_url | sed -e 's#^'"$(get_svn_repo_root)"'##g' | awk -F/ '{print $2 }'
}
get_git_branch() {
__git_ps1 2>/dev/null | sed -ne 's# (\(.*\))#\1#p'
}
get_repo_branch() {
local git_branch=$(get_git_branch | sed -ne 's#\(.*\)#(git|\1)#p')
local svn_branch=$(get_svn_branch | sed -ne 's#\(.*\)#(svn|\1)#p')
local branch="${git_branch}${svn_branch}"
#echo -n "${branch:--}"
echo -n "${branch}"
}

function gerritPush() {
   git push -v origin HEAD:refs/for/$(get_git_branch)
}

########################################
# Prompt
# Reference: http://tldp.org/HOWTO/Bash-Prompt-HOWTO
# for i in `seq 1 7 ; seq 30 48 ; seq 90 107 `; do echo -e "\033[${i}mtest \033[0m$i"; done

function SetDefaultPrompt {
   
   local LAST_RESULT=$?
   
   local            RED="\[\033[0;31m\]"
   local          GREEN="\[\033[0;32m\]"
   local         YELLOW="\[\033[0;33m\]"
   local           BLUE="\[\033[0;34m\]"
   local     LIGHT_GRAY="\[\033[0;37m\]"
   local           GRAY="\[\033[1;30m\]"
   local      LIGHT_RED="\[\033[1;31m\]"
   local    LIGHT_GREEN="\[\033[1;32m\]"
   local   LIGHT_YELLOW="\[\033[1;33m\]"
   local     LIGHT_BLUE="\[\033[1;34m\]"
   local   LIGHT_PURPLE="\[\033[1;35m\]"
   local          WHITE="\[\033[1;37m\]"
   local      NO_COLOUR="\[\033[0m\]"
   
   case $TERM in
   xterm*)
   local TITLEBAR='\[\e]0;\w\a\]'
   ;;
   *)
   local TITLEBAR=''
   ;;
   esac
   
   if [ $LAST_RESULT -eq 0 ] ; then PROMPT_SYMBOL="\$" ; else PROMPT_SYMBOL="${RED}\$" ; fi
   
   local branch=$(get_repo_branch)
   local hostnam=$(echo -n $HOSTNAME | sed -e "s/[\.].*//")
   local usernam=$(whoami)
   local usePWD=$(echo -n $PWD | sed "s|^$HOME|~|g")
   
   local temp_prompt="[(${usernam}@${hostnam}:${branch}):${usePWD}]"
   local fillsize=$(( ${COLUMNS} - ${#temp_prompt} ))
   
   if [ "$fillsize" -lt "0" ]
   then
      local cut=$(( 3 - ${fillsize} ))
      #usePWD="...${usePWD:${cut}}"
   fi
   
   #PS1="$TITLEBAR\n$LIGHT_BLUE[$LIGHT_PURPLE${usernam}@${hostnam}:$YELLOW${branch}$LIGHT_PURPLE:${usePWD}$LIGHT_BLUE]$NO_COLOUR\n${PROMPT_SYMBOL}${NO_COLOUR} "
   PS1="$TITLEBAR\n$LIGHT_BLUE[$LIGHT_GREEN${usernam}@${hostnam} $YELLOW${usePWD} $LIGHT_GREEN${branch}$LIGHT_BLUE]$NO_COLOUR\n${PROMPT_SYMBOL}${NO_COLOUR} "
   #export PS1="\[\e]0;\W\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \[\033[32m\]\$(parse_git_branch1)\[\033[00m\] \n\$ "
   #export PS1="$LIGHT_BLUE[$LIGHT_PURPLE\u@\h:\w$LIGHT_BLUE]$NO_COLOUR\n\$ "
   #export PS1='\[\033[1;33m\][\u@\h:\w]\[\033[0m\]\n\$ '
}

PROMPT_COMMAND=SetDefaultPrompt

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${SDK_PATH}/platform-tools:${SDK_PATH}/tools:${NDK_PATH}:${PATH}"

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH
