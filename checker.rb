#! ruby -Ks
#↑文字コードをSJISに指定する Ku: UTF

$LOAD_PATH << File.dirname(File::expand_path(__FILE__))

	class Checker
		require "dictionary"

		def initialize(dictionary)
			@dictionary = dictionary # of grouped keywords
		end
		
		# returns hash of |group name, array of found keywords|
		def findKeywords(texts)
			text = ""
			if texts.class == Array #concatenate lines
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

			#puts text
			
			@dictionary.each{
				|group, keywords|
				puts "group: " + group

				for keyword in keywords
					#puts "keyword: " + keyword.to_s
					# prepare regular expression
					reg = nil
					if keyword.class == String
						reg = Regexp.new(keyword)
					else
						reg = keyword
					end
					# do match
					match = text.match(reg)
					#puts reg.inspect
					while match != nil
						puts match[0]
						onKeywordFound(group, match[0], result)
						match = text.match(reg, match.begin(0) + match[0].length)
					end
				end

			}
			
			return result
		end

		# a procedure called when a keyword has been found at findKeywords().
		# usually you will put the keyword into result hash |group, array of keywords|
		# override this for other action
		def onKeywordFound(group, keyword, result)
			result[group] |= [keyword]
		end

		# converts the result of findkeywords() into CSV style
		# you can modify how it will be by overriding
		# onConvert()
		def toCSV(results)
			puts "------ to csv -------"
			#puts results
			
			csv = createHeader() + "\n"
			results.each{
				|name, resultHash|
				csv += toCSVPart(name, resultHash)
				
			}
			#puts csv
			return csv
		end
		
		# a method for creating titles in CSV
		def createHeader()
			header = escape("name")
			@dictionary.each_key{
				|group|
				header += toAppendable(group)
			}
			
			header
		end
		
		# a procedure called when a result for a block of code is converted.
		# Default definition calls onConvert() for each |group, keyword array|
		# and concatenates them.
		# It must retun element of CSV as string.
		# override for other action
		def toCSVPart(name, resultHash)

			line = ""
			line +=  escape(name)
			
			resultHash.each{
				|group, keywords|
				line += onConvert(name, group, keywords)
			}
			
			line + "\n"
		end

		# a procedure called when a pair |group, keywords| 
		# in the result of findKeywords() is converted into CSV style
		# It must return element of CSV as string.
		# override for other action
		def onConvert(name, group, keywords)
				if keywords.length > 0
					return  toAppendable("1")
				else
					return toAppendable("")
				end
		end

		# useful method for concatenating value to CSV line
		def toAppendable(value)
			", " + escape(value)
		end

		def escape(text)
			if text == nil
				return ""
			end
			
			escaped = text.gsub(/[\t+]/, " ")
			
			if text.match(/[\"\,\s]/) == nil
				return escaped
			end
			
			escaped = "\"" + text.gsub("\"", "\"\"") + "\""
			return escaped
		end
		
		# methods wrapping toCSV

		# &onEachDecoded should return a hash of |group, keywords|
		def createCSV(file_name, code, noComment=true, &onEachDecoded)
			require "decoder"
			decoder = Decoder.new
			
			results = Hash.new

			decoder.eachFunctions(code, noComment){
				|decoded|
				#puts func
				results[decoded.name] = onEachDecoded.call(decoded)
			}

			

			csv = file_name + "\n" + toCSV(results)

			csv
	
	
		end
		
		
		def createCommentCSV(file_name, code)

			csv = createCSV(file_name, code, false){
				|decoded|
				puts "--------- comment csv ------------"
				p decoded
				findKeywords(decoded.comments)
			}

			csv
		end
		
		def createBodyCSV(file_name, code)

			csv = createCSV(file_name, code){
				|func|
				#puts func
				findKeywords(func.body)
			}

			csv
		end
		
	end


