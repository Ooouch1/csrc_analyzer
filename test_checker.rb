#! ruby -Ks
$LOAD_PATH << File.dirname(File::expand_path(__FILE__))

require "checker"

# test codes

	# a sample code of Checker
	# If you work hard, you may construct a javadoc-like documentation software
	# with Decoder class.

	file_name = ARGV[0]
	csv_name = ARGV[1]

	def append? 
	 (ARGV[2] == "y")
	end
	if file_name == nil
		raise "give me c source file!"
	end

	if csv_name == nil
		csv_name = File.basename(file_name, ".*") + ".csv"
	end

	code = nil
	open(file_name){
		|file|	
		code = file.read
	}

	dict = Dictionary.new()
	dict.load("dict.txt")
	checker = Checker.new(dict)

	csv = checker.createBodyCSV(file_name, code)
	csv += checker.createCommentCSV(file_name, code)

	puts csv

	operation = "w"
	if append?
		operation = "a"
	end
	open(csv_name, operation){
		|file|
		
		file.write csv
	}

