#!/bin/bash

NWNX_EXECS=`find "/usr/local/bin/nwnx2-linux" -name "nwnx_*.so"`
NWNX_DIR="/opt/nwnserver"

# Remove any potential plugins
rm nwnx_*.so

find_nwnx_executable() {
    ARG=$1
    ARG_NODASH="${ARG/--/}"
    FILE=`echo "$NWNX_EXECS" | egrep "nwnx_(odmbc_)?$ARG_NODASH.so"`
}

find_nwnx_executable $1

while [[ -f $FILE ]]; do
    if [[ $ARG_NODASH =~ (mysql|pgsql|sqlite) ]]; then
        ln -s "$FILE" "$NWNX_DIR/nwnx_odbc.so"
        ./enabledb.pl -d$ARG_NODASH
        sed -i -e "s/^server=localhost$/server=db/g" nwnx2.ini
        sed -i -e "s/^user=username$/user=root/g" nwnx2.ini
    else
        ln -s "$FILE" "$NWNX_DIR/nwnx_$ARG_NODASH.so"
    fi
    shift
    find_nwnx_executable $1
done

./compose-nwnstartup.sh "$@"
