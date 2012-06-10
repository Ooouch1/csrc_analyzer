#! ruby -Ks
#↑文字コードをSJISに指定する Ku: UTF


	class Checker

		def initialize(dictionary = nil)
			@dictionary = dictionary # of grouped keywords

			if dictionary == nil
					require "./dictionary"
					@dictionary = loadDictionary
					
					puts @dictionary
			end
		end
		
		# returns hash of |group name, array of found keywords|
		def findKeywords(texts)
			text = ""
			if texts.class == Array
				for t in texts
					text += t
				end
			else
				text = texts
			end
			
			puts "------ find keywords --------"
			result = Hash.new()

			@dictionary.each_key{
				|group|
				result[group] = Array.new
			}

			puts text
			
			@dictionary.each{
				|group, keywords|
				puts "group: " + group

				for keyword in keywords
					puts "keyword: " + keyword
					match = text.match(Regexp.new(keyword))
					p match
					if match != nil
						onKeywordFound(group, keyword, result)
					end
				end

			}
			
			return result
		end

		# a procedure called when a keyword has been found at findKeywords()
		# override this for other action
		def onKeywordFound(group, keyword, result)
			result[group] |= [keyword]
		end

		# converts the result of findkeywords() into CSV style
		# you can modify how it will be by overriding
		# onConvert()
		def toCSV(results)
			puts "------ to csv -------"
			puts results
			
			csv = createHeader() + "\n"
			results.each{
				|name, resultHash|
				csv += toCSVLine(name, resultHash) + "\n"
				
			}
				
			csv
		end
		
		# a method for creating titles in CSV
		def createHeader()
			header = quote("name")
			@dictionary.each_key{
				|group|
				header += toAppendable(group)
			}
			
			header
		end
		
		def toCSVLine(name, resultHash)

			line = ""
			line +=  quote(name)
			
			resultHash.each{
				|group, keywords|
				line += onConvert(group, keywords)
			}
			
			line
		end

		# a procedure called when a pair |group, keywords| 
		# in the result of findKeywords() is converted into CSV style
		# override for other action
		def onConvert(group, keywords)
				if keywords.length > 0
					return  toAppendable("○")
				else
					return toAppendable("")
				end
		end

		# useful method for concatenating value to CSV line
		protected
		def toAppendable(value)
			", " + quote(value)
		end

		def quote(text)
			if text.match(" ") == nil
				return text
			end
			return "\"" + text + "\""
		end
	end

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


	operation = "w"
	if append?
		operation = "a"
	end
	open(csv_name, operation){
		|file|
		
		file.write csv
	}

