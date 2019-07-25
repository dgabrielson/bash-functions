#!/bin/bash

function tunnel-ssh-rac()
{
    local tunnel_host=$1
    local rac_host=$2

    echo "Open https://localhost/ to use the RAC"
    echo "CTRL+C when done"
    echo "sudo ssh ..."
    sudo ssh -L 443:${rac_host}:443 \
             -L 5900:${rac_host}:5900 \
             -L 5901:${rac_host}:5901 \
             -N ${tunnel_host}

}



function rac-tunnel-kvm1()
{
    tunnel-ssh-rac statsadmin@10.45.3.152 kvm1-rac
}


function vm-web-tunnel()
{
    local vmhost=$1
    local target=$2

    if [ -z "${vmhost}" ] or [ -z "${target}" ]; then
        echo "vm-web-tunnel <vm-host> <target:port>"
        return
    fi

    echo "Open http://localhost:8080 to use remote website"
    echo "CTRL+C when done"
    ssh -L 8080:${target} -N ${vmhost}
}

function remote-virsh()
{
    local fwdhost=$1
    local vmhost=$2
    shift 2

    if [ "${vmhost}" != "-" ]; then
        ssh -At "${fwdhost}" ssh -o LogLevel=QUIET -t "${vmhost}" /usr/bin/sudo /usr/bin/virsh "$@"
    else
        ssh -At "${fwdhost}" /usr/bin/sudo /usr/bin/virsh "$@"
    fi
}

function vm-math()
{
    remote-virsh gabriels@kvm0.math.umanitoba.ca - "$@"
}

function vm-stats-kvm0()
{
    remote-virsh statsadmin@10.45.3.152 - "$@"
}

function vm-stats-kvm1()
{
    remote-virsh statsadmin@10.45.3.152 kvm1 "$@"
}
