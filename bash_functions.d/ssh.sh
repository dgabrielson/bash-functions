#!/bin/bash

#REMOTE_TERM="'( screen -dRR )'"
#REMOTE_TERM="'( tmux attach || tmux new || screen -dRR )'"
#REMOTE_TERM="'( tmux -CC attach || tmux -CC new || screen -dRR )'"
REMOTE_TERM="'(tmux -CC attach -t ''\$(hostname -f | tr . -)'' || tmux -CC new -s ''\$(hostname -f | tr . -)'' )'"


function ssh-proxy-call-port()
{
    local user=$1
    local host=$2
    local port=$3
    local name=$4
    # last arg(s) optional:
    local fwd_host=$5
    shift 5

    if [ -z "${fwd_host}" ]; then
        tabname "${name}"
        ssh -At -p ${port} "${user}@${host}" bash -c "${REMOTE_TERM}"
    elif [ -z "$1" ]; then
        tabname "${name} -> ${fwd_host}"
        ssh -At -p ${port} "${user}@${host}" ssh -o LogLevel=QUIET -t "${fwd_host}" "${REMOTE_TERM}"
    else
        #tabname "${name} -> ${fwd_host} -> $@"
        ssh -At -p ${port} "${user}@${host}" ssh -o LogLevel=QUIET -t "${fwd_host}" "$@"
    fi

    if [ $# -eq 0 ]; then
        # after ssh is done, reset the tabname
        tabname "$(pwd)"
    fi
}

function ssh-proxy-call()
{
    local user=$1
    local host=$2
    shift 2

    ssh-proxy-call-port ${user} ${host} 22 "$@"
}


function ssh-rsync-proxy()
{
    local user_host=$1
    shift 1

    ssh_proxy="ssh -A ${user_host} ssh"

    rsync --progress -e "${ssh_proxy}" "$@"
}

function ssh-math()
{
    ssh-proxy-call gabriels kvm0.math.umanitoba.ca "kvm0 (math)" "$@"
}


function ssh-gauss()
{
    ssh-proxy-call mathadmin gauss.math.umanitoba.ca "gauss (math)" "$@"
}


function rsync-math()
{
    ssh-rsync-proxy gabriels@kvm0.math.umanitoba.ca "$@"
}


function rsync-gauss()
{
    ssh-rsync-proxy mathadmin@gauss.math.umanitoba.ca "$@"
}


function ssh-stats()
{
    ssh-proxy-call statsadmin cowboy.stats.umanitoba.ca "kvm0 (stats)" "$@"
}


function rsync-stats()
{
    ssh-rsync-proxy statsadmin@cowboy.stats.umanitoba.ca "$@"
}


function ssh-home()
{
    ssh-proxy-call dave home.gabrielson.ca "home" "$@"
}


function rsync-home()
{
    ssh-rsync-proxy dave@home.gabrielson.ca "$@"
}
