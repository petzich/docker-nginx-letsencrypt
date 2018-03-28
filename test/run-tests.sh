#!/bin/sh

cwd="$(dirname $0)"

for i in $(ls -1 ${cwd}/_test_*.sh); do
	./$i
done
