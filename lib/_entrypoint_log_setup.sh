#!/bin/sh

# Include log4sh for logging
LOG4SH_CONFIGURATION='none' . ${libdir}/log4sh
prepare_loglevel() {
	if [ ! -z ${ENTRYPOINT_LOGLEVEL} ]; then
		logger_setLevel "${ENTRYPOINT_LOGLEVEL}"
	else
		logger_setLevel INFO
	fi
}
prepare_loglevel
