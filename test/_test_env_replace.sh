#! /bin/sh

. ${testdir}/_init_log_setup.sh
. ${libdir}/_env_replace.sh

inputFile=/tmp/testInput.txt
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

testEnvReplaceString(){
	input='Hello ${a1}, ${b2}, $c3 and $d4'
	export a1="one"
	export b2="two"
	export c3="three"
	export d4="four"
	actual=$(env_replace_in_string "$input" "a1 b2 c3 d4 e5")
	assertEquals "Hello one, two, three and four" "$actual"
	actual=$(env_replace_in_string "$input" "a1 c3")
	assertEquals "Hello one, \${b2}, three and \$d4" "$actual"
	actual=$(env_replace_in_string "$input" "a2")
	assertEquals "Hello \${a1}, \${b2}, \$c3 and \$d4" "$actual"
	actual=$(env_replace_in_string "$input" "")
	assertEquals "Hello \${a1}, \${b2}, \$c3 and \$d4" "$actual"
	input='Hello ${a1} and $a1'
	actual=$(env_replace_in_string "$input" "a1")
	assertEquals "Hello one and one" "$actual"
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

. ${extlibdir}/shunit2/shunit2

