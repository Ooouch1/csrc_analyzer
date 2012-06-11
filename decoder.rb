
class DecodedFunction
	attr_accessor :name
	attr_accessor :body
	attr_accessor :comments
	attr_accessor :deleted
	attr_accessor :head
	attr_accessor :tail
	attr_accessor :inMacroIf	

	@deleted = false
	@inMacroIf = false
	
	def initialize(name = "", body = "", comments = nil)
		@name = name
		@body = body
		@comments = comments
	end
	
	def to_s()
		"name: \n"+ @name + 
		"\nbody: \n" + @body + 
		"\ncomments:\n" + comments.to_s()
	end
end

class Decoder

require "./lang_def"

	def removeComments(code)
		removed = code.gsub(@@COMMENT, "")
		puts "-------- all comments are removed ------------"
		puts removed
		
		return removed
	end

	#requires escaped text if you want to use "(", "*" and so on as a character
	def createCommentContaining(text)
	
		line = Regexp.new( @@LCOM_HEAD_S + @@LCOM_BODY_S + text.to_s() + @@LCOM_BODY_S + @@LCOM_TAIL_S )
		
		block = Regexp.new( @@BCOM_HEAD_S + @@BCOM_BODY_S + text.to_s() + @@BCOM_BODY_S +@@BCOM_TAIL_S)

		puts "-------- comment " + text.to_s() + " created ------------"
		puts "line pattern: "
		p line
		puts "block pattern"
		p block
	
		return Regexp.union(line, block)
	end

	def removeCommentsContaining(code, text)
		removed = code.gsub(createCommentContaining(text), "")
		puts "-------- comment " + text.to_s() +" are removed ------------"
		puts removed
		
		return removed
	end

	# returns all comments as array
	def extractComments(code)
		comments = extractAll(code, @@COMMENT)
		puts "-------- comments ---------"
		p comments
		return comments
	end

	require "./extracting"
	def extract(code, extracting_class, name, start_ = 0)
		puts "start extracting "
		puts name.to_s
		match = code.match(name, start_)

		# no exist
		if match == nil
			return nil
		end
		puts match[0]

		start = match.begin(0)
		state = extracting_class.new(start)
		puts start.to_s
		# solve by state pattern
		while (not state.isEnd(code)) and (state.index < code.length) 
			state = state.extract(code)
		end

		body = code[start..state.index]
		
		decoded = DecodedFunction.new(match[0] +" @"+ start.to_s, body)
		decoded.head = start
		decoded.tail = state.index

		puts "-------- extract ---------"
		puts start.to_s + "," + state.index.to_s
		puts decoded
		return decoded	
	end

	# detect #if ... #endif area
	def extractMacroIf(code, start)
		require "./extracting"

		
		decoded = extract(code, 
				ExtractingMacroIf, @@M_IF_SOME_HEAD, 0)

		if decoded != nil
			decoded.inMacroIf = true
		end
		
		puts "-------- inside of #if ---------"
		puts decoded
		return decoded
	end

	
	# this method assumes comments containing function def. are removed.
	# returns DecodedFunction whose body still contain comments.
	def extractFunction(code, name)
		require "./extracting"

		start = code.index(name)
		p start
		state = ExtractingCode.new(start)

		# solve by state pattern
		while (not state.isEnd(code)) and (state.index < code.length) 
			state = state.extract(code)
		end

		func = code[start..state.index]
		
		decoded = DecodedFunction.new(name, func, extractComments(func))
		decoded.head = start
		decoded.tail = state.index

		puts "-------- Func ---------"
		puts decoded
		return decoded
	end

	# returns array of DecodedFunction whose body still contain comments.
	def extractFunctions(code, names = nil)
	
		puts code
		if names == nil
			noFuncComment = removeCommentsContaining(code, @@FUNCTION_DEF)
			names = extractFuncNames( noFuncComment)
		end
		
		functions = Array.new()

		last_index = 0
		
		for name in names
			puts "start " + name
			puts "last: " + last_index.to_s

			func = extractFunction(code, name)

			last_index = func.tail + 1

			functions.push func
		end

		functions
	end

	def extractFunctions2(code, names = nil)
	
		puts code
		if names == nil
			noFuncComment = removeCommentsContaining(code, @@FUNCTION_DEF)
			names = extractFuncNames( noFuncComment)
		end
		
		functions = Array.new()

		last_index = 0
		
		for name in names
			puts "start " + name
			puts "last: " + last_index.to_s

			func = extractFunction(code, name)

			last_index = func.tail + 1

			functions.push func
		end

		functions
	end
	# warning: this method catches function def. in comments as well
	def extractFuncNames(code)
		names = extractAll(code, @@FUNCTION_DEF)

		puts "------ names ------"

		puts "func def."
		puts names
		p @@FUNCTION_DEF

		return names
	end

	def extractAll(code, reg)

		found = Array.new()
		extractAllAsMatch(code, reg).each{
			|m|
			found.push m[0]
		}
		return found
	end

	def extractAllAsMatch(code, reg)
		found = Array.new()
		puts "-------- extract all ------"
		p reg

		match = reg.match(code) 

		while(match != nil)
			matched = match[0]
			found.push match
			index = match.begin(0)
			match = reg.match(code, index + matched.length) 
		end
		return found
	end

	def eachFunctions(code, &onEach)

		functions = extractFunctions(code)
		for func in functions
			onEach.call(func)
		end

	end

end

# test codes
#dec = Decoder.new()
#
#code = nil;
#
#
#open("test.c"){
#	|file|
#	code = file.read
#}

#puts dec.extractComments code
#dec.removeComments code
#dec.extractFunctions code


