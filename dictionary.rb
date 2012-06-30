$LOAD_PATH << File.dirname(File::expand_path(__FILE__))

class Dictionary < Hash
		ERROR_CODE = "wrong dictionary file"

	class SeekableString < String
		attr_accessor :index
		
		def initialize
			@index = 0
		end
	
		def overLength?
			return @index >= self.length
		end
	end

	# loading from external file.
	# The format is:
	# "group"
	# ["keyword1", "2", ...]
	# "group2"
	# ["","",...]
	# ...
	def load(file_name)		
	
		text = SeekableString.new
		
		open(file_name){
			|file|
			text << file.read()
		}
		
#		text.gsub!(/\n/, " ")
		
		puts text
		
		while  not text.overLength?
		
			group = getGroup(text)
			keywords = getKeywords(text)
	
			if group == nil || keywords == nil
				break
			end
			
			if keywords.class != Array
				raise ERROR_CODE
			end

=begin			
			keywords.each{
				|k|
				if k.class != string
					raise ERROR_CODE
				end
			}
=end
			
			self[group] = keywords
		end

	end

	# Sorry, string including "\"" is not allowed as a group
	def getGroup(text)
		match = text.match(/"[^"]+"?/, text.index)

		group  = ""
		if match != nil
			group = match[0]
			text.index = match.begin(0) + group.length
		else 
			raise ERROR_CODE
		end

		eval group
	end
	
	# Sorry, string including "[" or "]" is not allowed as a keyword
	def getKeywords(text)
#		match = text.match(/\[[^\[\]]*\]?/, text.index)

		head = text.match(/\[/, text.index)
		tail = text.match(/\]\n/, text.index)


		keywords = ""
		if head != nil and tail != nil
			keywords = text[head.begin(0)..tail.begin(0)]
			text.index = tail.begin(0) + tail[0].length
		else 
			raise ERROR_CODE
		end

		puts keywords
		
		eval keywords
	end

end


# use if Dictionary.load() can't do his job ^^
def loadDictionary
	dictionary = Dictionary.new  # hash of |group, keyword array||

	dictionary["loop"] =
	["for","while"]

	dictionary["condition"] =
	["if"]
	
	dictionary
end

