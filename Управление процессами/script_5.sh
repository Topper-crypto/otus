#!/bin/bash
rm -rf ./test*
dd if=/dev/zero of=/testdir/testfile bs=128MB count=1 oflag=direct

function hi {
d1=$(date +%s)
nice -n -20 tar caf /testdir/testhi.tar.xz /testdir/testfile
d2=$(date +%s)
echo "HI "$(expr $d2 - $d1)
}

function low {
d1=$(date +%s)
nice -n 20 tar caf /testdir/testlow.tar.xz /testdir/testfile
d2=$(date +%s)
echo "LOW "$(expr $d2 - $d1)
}

low &
hi &

wait
