#!/bin/bash

# What platform? Should be "Darwin" or "Linux"
UNAME=$(uname)


if [ "${UNAME}" == "Darwin" ]; then
    if [ -x "/usr/local/bin/virtualenvwrapper_lazy.sh" ]; then
        . /usr/local/bin/virtualenvwrapper_lazy.sh
    fi
fi
# if [ "${UNAME}" == "Linux" ]; then
#     ; # Usually this is added by the system...
# fi
