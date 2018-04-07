#!/bin/sh

# Configure the loggers to use when running the tests
# Two loggers are used:
# 1. a FileAppender that mimicks the use of the standard appender (but does not log to stdeer)
# 2. a FileAppender that logs at TRACE level so tests can be run

wd=$(dirname $0)

testStdErr="/tmp/testStdErr"
testTraceLog="/tmp/testTraceLog"

# Generate the logging files
echo "" > $testStdErr
echo "" > $testTraceLog
if [ ! -f $testStdErr ]; then echo "LOGGING file does not exist"; fi
if [ ! -f $testTraceLog ]; then echo "LOGGING file does not exist"; fi

# Include log4sh for logging
LOG4SH_CONFIGURATION="none" . ${extlibdir}/log4sh/log4sh
log4sh_resetConfiguration

logger_setLevel INFO

logger_addAppender stderr
appender_setLevel stderr INFO
appender_setType stderr FileAppender
appender_file_setFile stderr $testStdErr
appender_setLayout stderr PatternLayout
appender_setPattern stderr "[%-5p] %m"
appender_activateOptions stderr

logger_addAppender trace
appender_setLevel trace TRACE
appender_setType trace FileAppender
appender_file_setFile trace $testTraceLog
appender_setLayout trace PatternLayout
appender_setPattern trace "[%-5p] %m"
appender_activateOptions trace

