#!/bin/sh

# Contains functions for handling derived images

. $libdir/_env_replace.sh

# Copy files from one path to another
# Parameters:
# 1. Source directory
# 2. Destination directory
copy_files() {
	local srcdir=$1
	local destdir=$2
	if [ -d $srcdir ]
	then
		cp -a ${srcdir}/* $destdir
	else
		logger_warn "Source directory $srcdir does not exist"
	fi
}

# Replace environment variables in files with the pattern
# Parameters:
# 1. Directory to look for files
# 2. Pattern of the file extension
# 3. Space-separated list of environment variable names
files_replace_vars() {
	local directory=$1
	local extension=$2
	local envnames=$3
	if [ -d $directory ]
	then
		cd $directory
		local filenames=$(ls -1 $directory/*.$extension)
		logger_trace "filenames: $filenames"
		local extensionLength=$(echo $extension | wc -m)
		local cutLength=$(($extensionLength + 1))
		logger_trace "cutLength: $cutLength"
		local inFile
		for inFile in $filenames
		do
			local outFile=`echo $inFile | rev | cut -c "$cutLength"- | rev`
			logger_info "Replacing env vars in $inFile. Renaming to $outFile"
			env_replace_in_file $inFile $outFile "$envnames"
		done
	else
		logger_warn "Directory $directory does not exist"
	fi
}

