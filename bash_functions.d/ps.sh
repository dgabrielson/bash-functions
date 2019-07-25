#!/bin/bash

function zombieparents
{
    ps -xaw -o state,ppid | grep Z | grep -v PID | awk '{ print $2 }' 
}


function pscount
{
    ps axwwo command | sed 1d | sort | uniq -c | sort -nr --key=1,1
}

