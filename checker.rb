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
					puts "keyword: " + keyword.to_s
					# prepare regular expression
					reg = nil
					if keyword.class == String
						reg = Regexp.new(keyword)
					else
						reg = keyword
					end
					# do match
					match = text.match(reg)
					puts reg.inspect
					if match != nil
						puts match[0]
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
			puts csv
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
		def toAppendable(value)
			", " + quote(value)
		end

		def quote(text)
			if text.match(/[\"\,\s]/) == nil
				return text
			end
			return "\"" + text.gsub("\"", "\"\"") + "\""
		end
		

		# &onEachFunc should return a hash of |group, keywords|
		def createCSV(file_name, code, &onEachFunc)
			require "./decoder"
			decoder = Decoder.new
			
			results = Hash.new

			decoder.eachFunctions(code){
				|func|
				results[func.name] = onEachFunc.call(func)
			}

			csv = file_name + "\n" + toCSV(results)

			csv
	
	
		end
		
		# methods wrapping toCSV
		
		def createCommentCSV(file_name, code)

			csv = createCSV(file_name, code){
				|func|
				findKeywords(func.comments)
			}

			csv
		end
		
		def createBodyCSV(file_name, code)

			csv = createCSV(file_name, code){
				|func|
				findKeywords(func.body)
			}

			csv
		end
		
		def createNameCSV(code)
			
		end
	end


