#!/bin/sh

wd=$(dirname $0)

# Include log4sh for logging
LOG4SH_CONFIGURATION="${wd}/log4sh.properties" . ${extlibdir}/log4sh/log4sh
