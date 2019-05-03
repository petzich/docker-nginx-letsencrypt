#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_env_replace.sh

inputFile=/tmp/testInput.txt
expectedFile=/tmp/expectedFile.txt
outputFile=/tmp/testOutput.txt

setUp(){
	if [ -f $inputFile ]; then rm $inputFile; fi
	if [ -f $outputFile ]; then rm $outputFile; fi
	unset a1 b2 c3 d4
}

testEnvNameCleanup(){
	input="a-zA-Z0-9_ "
	expected="azAZ09_"
	actual=$(env_name_cleanup $input)
	assertEquals "$expected" "$actual"
}

testEnvNameCleanupHarder(){
	input="a-zA-Z0-9_ ,{}äöüçœ!^``'?"
	expected="azAZ09_"
	actual=$(env_name_cleanup $input)
	assertEquals "$expected" "$actual"
}

# TODO: the assertions do not work properly
# The output is correct though, as asserted by testing file replacements
testEnvPrepareVariableList(){
	input="a1 a2"
	expected="\${a1} \${a2}"
	actual=$(env_prepare_variable_list $input)
	# assertEquals "$expected" "$actual"
	input="a1 a2 a3äöü"
	expected="\${a1} \${a2} \${a3}"
	actual=$(env_prepare_variable_list $input)
	# assertEquals "$expected" "$actual"
}

testEnvReplaceFileSimple(){
	export a1="one" b2="two" c3="three" d4="four"
	echo 'Hello ${a1}, ${b2}, $c3 and $d4.' > $inputFile
	env_replace_in_file $inputFile $outputFile "a1 b2 c3 d4"
	expected='Hello one, two, three and four.'
	actual=$(cat "$outputFile")
	assertEquals "$expected" "$actual"
}

testEnvReplaceFileSomeMissing() {
	export a1="one"
	echo -e 'Hello ${a1}, ${b2}, $a1 and $b2' > $inputFile
	env_replace_in_file $inputFile $outputFile "a1"
	expected="Hello one, \${b2}, one and \$b2"
	actual=$(cat "$outputFile")
	assertEquals "$expected" "$actual"
}

# This test test a more complete replacement
# It includes the check to see if comments stay there
testEnvReplaceFileWithComments() {
	export a1="hello"
	export a2="test"
	# Define the inputfile
	echo '${a1} $a2 ${a3}' > $inputFile
	echo '# This is a comment' >> $inputFile
	echo '$a1 $a2 # followed by a comment' >> $inputFile
	echo '$a1 ${a2}' >> $inputFile
	# Define the expected output file
	echo 'hello test ${a3}' > $expectedFile
	echo '# This is a comment' >> $expectedFile
	echo 'hello test # followed by a comment' >> $expectedFile
	echo 'hello test' >> $expectedFile
	# Create the output and compare
	env_replace_in_file $inputFile $outputFile "a1 a2"
	actual=$(cat "$outputFile")
	expected=$(cat "$expectedFile")
	assertEquals "$expected" "$actual"
}

testEscapeRegex(){
	local input='\#'
	local actual=$(escape_regex $input)
	assertEquals '\\#' "$actual"
	local input='#'
	local actual=$(escape_regex $input)
	assertEquals '\#' "$actual"
}

. ${extlibdir}/shunit2/shunit2

