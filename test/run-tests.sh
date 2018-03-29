#!/bin/sh

export testdir="$(dirname $0)"
export libdir=$(readlink -f "${testdir}/../lib")
export extlibdir=$(readlink -f "${testdir}/../extlib")
echo "libdir for tests is:    ${libdir}"
echo "extlibdir for tests is: ${extlibdir}"

for i in $(ls -1 ${testdir}/_test_*.sh); do
	./$i
done
