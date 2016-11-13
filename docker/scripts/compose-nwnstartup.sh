#!/bin/sh

export LD_PRELOAD=./nwnx2.so
export LD_LIBRARY_PATH=lib/:$LD_LIBRARY_PATH

./nwserver "$@"
