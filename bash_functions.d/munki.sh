#!/bin/bash

function autopkgr
{
    /Applications/AutoPkgr.app/Contents/MacOS/AutoPkgr -runInBackground YES
}

function munkiprune
{
    ~/src/munki-prune/src/munkiprune.py "$@"
}


function munkipush
{
    tabname "Pruning..."
    echo "### pruning repo ###"
    munkiprune -q -k 2
    tabname "Synchronizing live Munki repo"
    echo "### updating permissions ###"
    chmod -R a+rX ~/munki
    echo "### updating munki catalogs ###"
    /usr/local/munki/makecatalogs ~/munki/ > /dev/null
    echo "### push to kvm0.stats:/storage/ ###"
    /usr/bin/rsync -auvK --delete-after ~/munki statsadmin@10.45.3.152:/storage/host/munki/html/
    tabname $(pwd)
}


