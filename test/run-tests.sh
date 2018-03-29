#!/bin/sh

cwd="$(dirname $0)"
export libdir=$(readlink -f "${cwd}/../lib")
export extlibdir=$(readlink -f "${cwd}/../extlib")
echo "libdir for tests is:    ${libdir}"
echo "extlibdir for tests is: ${extlibdir}"

for i in $(ls -1 ${cwd}/_test_*.sh); do
	./$i
done
