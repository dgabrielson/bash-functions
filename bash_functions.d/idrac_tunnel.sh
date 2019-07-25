
function ssh-idrac-tunnel()
{
    local gateway=$1
    local idrac=$2

    if [[ -z ${gateway} ]]; then
        echo "You must supply the ssh-able host to tunnel through."
        return 1
    fi

    if [[ -z ${idrac} ]]; then
        echo "You must supply the hostname of the iDRAC you want to setup a tunnel for."
        return 1
    fi

    echo "Local machine password to forward privaledged ports:"
    sudo true
    echo "https://localhost/login.html"
    bash -c '( sleep 2s && open https://localhost/login.html )' &
    echo "Use CTRL+C when done"
    sudo ssh -N -L 443:${idrac}:443 -L 5900:${idrac}:5900 -L 5901:${idrac}:5901 ${gateway}
}


function gauss-idrac-tunnel()
{
    ssh-idrac-tunnel mathadmin@gauss.math.umanitoba.ca "$@"
}


function math-idrac-tunnel()
{
    ssh-idrac-tunnel gabriels@kvm0.math.umanitoba.ca "$@"
}


function idrac-brunswick()
{
    math-idrac-tunnel brunswick-rac
}


function idrac-havana()
{
    gauss-idrac-tunnel havana-rac
}


function idrac-panama()
{
    gauss-idrac-tunnel panama-rac
}


function idrac-gauss()
{
    local n=$1
    if [[ -z $n ]]; then
        echo "You must specify which node, e.g.:"
        echo "idrac-gauss node101"
        return 1
    fi
    gauss-idrac-tunnel ${n}-rac
}


function idrac-stats-kvm1()
{
    ssh-idrac-tunnel statsadmin@10.45.3.152 kvm1-rac
}


function idrac-math-kvm0()
{
    open https://kvm0.math.umanitoba.ca/login.html
}


function idrac-sec()
{
    open https://sec-rac.stats.umanitoba.ca/login.html
}
function idrac-caan()
{
    open https://caan-rac.stats.umanitoba.ca/login.html
}
function idrac-thay()
{
    open https://thay-rac.stats.umanitoba.ca/login.html
}
function idrac-jast()
{
    open https://jast-rac.stats.umanitoba.ca/login.html
}
