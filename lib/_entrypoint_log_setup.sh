#!/bin/sh

# Include log4sh for logging
LOG4SH_CONFIGURATION="${libdir}/log4sh.properties" . ${libdir}/log4sh

# Override loglevel from env variable, if set.
if [ ! -z ${ENTRYPOINT_LOGLEVEL} ]; then
	logger_setLevel "${ENTRYPOINT_LOGLEVEL}"
fi
