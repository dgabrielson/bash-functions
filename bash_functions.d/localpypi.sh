#!/bin/bash

###################################################
# Colour Definitions
###################################################

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

###################################################

function colourize()
{
    local color=$1
    local text=$2
    local reset='\e[0m' # No Color
    printf "${color}${text}${reset}"
}

###################################################

function success()
{
    printf "\n $(colourize ${Green} ✔) $@\n\n"
}


function warning()
{
    printf "\n $(colourize ${Yellow} ❗) $@\n\n"
}


function error()
{
    printf "\n $(colourize ${Red} ❌) $@\n\n"
}


###################################################

function localpypi()
{
    # precheck:
    if [ ! -f setup.py ]; then
        error "No setup.py here!"
        return
    fi
    # cleanup previous builds
    rm -rf build
    rm -rf *.egg-info

    # prechecks
    if python setup.py check; then
        success "Precheck okay."
    else
        error "Setup Check failed!"
        return
    fi
    if ! which -s check-manifest; then
        error "check-manifest not found: pip install check-manifest"
        return
    fi
    if ! check-manifest -u; then
        error "Update your MANIFEST.in before continuing"
        return
    fi
    if ! which -s isort ; then
        error "isort not found: pip install isort"
        return
    fi
    if ! isort --apply --atomic --dont-skip __init__.py --multi-line=3 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88; then
        error "isort error: fix before continuing"
        return
    fi
    if ! which -s black ; then
        error "black not found: pip install black"
        return
    fi
    if ! black . ; then
        error "black error: fix before continuing"
        return
    fi
    # check if this is mercurial
    if [ -d .hg ]; then
        # if so, check for uncommitted changes
        if hg summary | grep -q 'commit: (clean)'; then
            # tag current version
            local version="$(python setup.py --version)"
            hg tag "${version}"
            success "Tagged to \"${version}\""
        else
            hg summary
            echo
            hg status
            warning "You have uncommitted changes!"
            return
        fi
        # push the tagged version out.
        hg push
    else
        warning "(Not a mercurial repository.)"
    fi

    # bundle and upload source distribution & wheel
    #   see: http://pythonwheels.com/
    python setup.py sdist bdist_wheel --universal || error "Requires: pip install wheel"
    if ! which -s twine; then
        error "twine not installed; please install before continuing"
        return
    fi
    twine upload -r localpypi dist/*
    rm -rf build dist
}
