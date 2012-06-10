#! ruby -Ks
#↑文字コードをSJISに指定する Ku: UTF


class Checker

	def initialize(dictionary = nil)
		@dictionary = dictionary

		if dictionary == nil
				require "./dictionary"
				@dictionary = loadDictionary
				
				puts @dictionary
		end
	end
	
	def findKeywords(texts)
		puts "------ find keywords --------"
		result = Hash.new()

		@dictionary.each_key{
			|group|
			result[group] = Array.new
		}
		
		for text in texts
			puts text
			
			@dictionary.each{
				|group, keywords|
				puts "group: " + group
				for keyword in keywords
					puts "keyword: " + keyword
					match = text.match(Regexp.new(keyword))
					p match
					if match != nil
						result[group].push match[0] #完全マッチの文字列を追加する
					end

				end

			}
		end
		
		return result
	end

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
	
	def createHeader()
		header = quote("name")
		@dictionary.each_key{
			|group|
			header = addToCSVLine(header, group)
		}
		
		header
	end
	
	def toCSVLine(name, resultHash)

		line = ""
		line +=  quote(name)
		
		resultHash.each{
			|group, keywords|
			if keywords.length > 0
				line = addToCSVLine(line, "○")
			else
				line = addToCSVLine(line, "")
			end
		}
		
		line
	end

	def addToCSVLine(line, value)
		line + ", " + quote(value)
	end

	def quote(text)
		if text.match(" ") == nil
			return text
		end
		return "\"" + text + "\""
	end
end

# サンプルコード
file_name = ARGV[0]

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

open(File.basename(file_name, ".*") + ".csv", "w"){
	|file|
	
	file.write csv
}

