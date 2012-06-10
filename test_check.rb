#! ruby -Ks

require "./check"

# test codes
def Checker::test

	# a sample code of Decoder and Checker
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

	require "./decoder"
	decoder = Decoder.new

	functions = decoder.extractFunctions(code)
	checker = Checker.new
	results = Hash.new()
	for func in functions
		results[func.name] = checker.findKeywords(func.comments)
	end

	#puts checker.createHeader()
	csv = file_name + "\n" + checker.toCSV(results)


	puts csv

	operation = "w"
	if append?
		operation = "a"
	end
	open(csv_name, operation){
		|file|
		
		file.write csv
	}

end

Checker::test

