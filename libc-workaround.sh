#!/bin/bash
set -e

fix_libc(){
    OLD_FILE=$1
    OLD_MD5SUM=$2
    NEW_FILE=$3
    NEW_MD5SUM=$4

    echo -n "Check $OLD_FILE ... "
    if [ ! -f "$OLD_FILE" ]; then
        echo "NOT EXISTS"
        return 1
    fi

    MD5SUM=$(md5sum "$OLD_FILE"  | awk '{print $1}')
    if [ "$MD5SUM" = "$NEW_MD5SUM" ]; then
        echo "ALREADY FIXED"
        return 1
    fi
    if [ "$MD5SUM" != "$OLD_MD5SUM" ]; then
        echo "MISMATCH"
        exit 1
    fi
    echo "NEED FIX"

    echo -n "Check $NEW_FILE ... "
    MD5SUM=$(md5sum "$NEW_FILE" | awk '{print $1}')
    if [ "$MD5SUM" != "$NEW_MD5SUM" ]; then
        echo "FAIL"
        exit 1
    fi
    echo "OK"
    echo -n "Fix $OLD_FILE ... "
    if ! rm "$OLD_FILE" || ! cp "$NEW_FILE" "$OLD_FILE"; then
        echo "FAIL"
        exit 1
    fi
    echo "OK"
}

if [ "$1" != "initialized" ]; then
    echo -n "Initialize environment(IMPORTANT) ... "
    if ! mkdir -p environment-tmp || ! cp /lib/x86_64-linux-gnu/libc.so.6 environment-tmp/; then
        echo "FAIL"
        exit 1
    fi
    echo "OK"
    LD_LIBRARY_PATH="$(pwd)/environment-tmp" bash "$0" initialized
    exit
fi

fix_libc /lib/x86_64-linux-gnu/libc-2.31.so 10fdeb77eea525914332769e9cd912ae amd64-libc/libc.so 6c44584881a413893968145b7bbeb10b || true
fix_libc /lib32/libc-2.31.so                cbb114efa0fbd4f4a15124c06f5bdecd amd64-i386/libc.so 46fb40599c1006d476ce6ac2c5526b3c || true
fix_libc /libx32/libc-2.31.so               51686bd9dc82f8be130040c87222a031 amd64-x32/libc.so  ed89e5f21f7b3b3d51786f717a49ca3e || true

echo "Complete! If this shell frozen, close this session and start another one"
