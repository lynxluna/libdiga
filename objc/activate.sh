#!/usr/bin/env bash

#source activate.rc
echo "SkyFyre tool are now activated"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLPATH="$DIR/tool"
PATH="$PATH:$TOOLPATH"

#echo $PATH

export PATH
