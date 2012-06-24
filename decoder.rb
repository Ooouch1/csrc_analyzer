$LOAD_PATH << File.dirname(File::expand_path(__FILE__))

class Decoded
	attr_accessor :name
	attr_accessor :body
	attr_accessor :comments

	attr_accessor :head
	attr_accessor :tail

	attr_accessor :inMacroIf
	attr_accessor :deleted

	
	def initialize(name = "", body = "", comments = nil, 
				head = 0, tail = 0, inMacroIf = false, deleted = false)
		@name = name
		@body = body
		@comments = comments
		@head = head
		@tail = tail
		@inMacroIf = inMacroIf
		@deleted = deleted
	end
	
	def to_s()
		"name: \n"+ @name + 
		"\nhead: " + @head.to_s() +
		"\ntail: " + @tail.to_s() +
		"\nbody: \n" + @body + 
		"\ncomments:\n" + comments.to_s()
	end
end

class Decoder
	LOG_FILE = "log.txt"
	
	attr_accessor :noComment
		
	require "lang_def"

	def removeMacroIfZero(code)
			macroIfs = extractMacroIfs(code, @@M_IF_ZERO_HEAD)
			removed = code
			if macroIfs != nil
				macroIfs.each{
					|mIf| removed = removed.gsub(mIf.body, "")
				}
			end			
			return removed
	end

	def removeComments(code)
		removed = code
		removed = removed.gsub(@@COMMENT, "")
		removed = removeMacroIfZero(removed)
		puts "-------- all comments are removed ------------"
		#puts removed
		
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
		#puts removed
		
		return removed
	end

	# returns all comments as array
	def extractComments(code)
		comments = extractAll(code, @@COMMENT)
		puts "-------- comments ---------"
		p comments
		return comments
	end

	require "extracting"
	def extract(code, extracting_class, name, start_ = 0)
		puts "start extracting "
		puts name.to_s
		
		reg = nil
		if name.class == String
			reg = Regexp.new(Regexp.escape(name))
	else
			reg = name
		end
		match = reg.match(code, start_)

		# no exist
		if match == nil
			return nil
		end
		puts match[0]

		# solve by state pattern
		start = match.begin(0)
		context = Context.new(start)
		state = extracting_class.new(context)
		puts start.to_s
		while (not state.isEnd(code))
			state = state.extract(code)
		end

		body = code[start..state.index]
		
		decoded = Decoded.new(match[0] +" @"+ start.to_s, body)
		decoded.head = start
		decoded.tail = state.index

		puts ("-------- extract "+ reg.inspect()+" ---------")
		puts decoded
		return decoded	
	end

	# detect #if ... #endif area. the area is set to body of Decoded.
	def extractMacroIf(code, start, reg = @@M_IF_SOME_HEAD)
		
		decoded = extract(code, 
				ExtractingMacroIf, reg, start)

		if decoded != nil
			decoded.inMacroIf = true
		end

		return decoded
	end

	
	# this method assumes comments containing function def. are removed.
	# returns Decoded whose body still contain comments.
	def extractFunction(code, name, start = 0)

		decoded = extract(code, 
				ExtractingCode, name, start)
	
		if decoded == nil
			require "logger"
			msg = "nil func for "+ name +" @ extractFunctions()\n"
			Logger.new(LOG_FILE).error msg
		else 
			decoded.name = name
		end
		
		return decoded
	end

	# returns array of Decoded
	def extractFunctions(code, names = nil)
	
		puts code

		if names == nil
			names = extractFuncNames( code)
		end
		
		functions = Array.new()

		last_index = 0
		
		for name in names
			puts "start " + name
			puts "last: " + last_index.to_s

			func = extractFunction(code, name, last_index)

			if func != nil
				if last_index > func.head
					require "logger"
					msg = "extraction failed, last: " + last_index.to_s() + "start: " + func.head.to_s() + func.name + "\n"
					Logger.new(LOG_FILE).error msg
				end
				last_index = func.tail
				
			end
			
			
			functions.push func
		end

		functions
	end

	# extracts all #if ... #end at top level
	def extractMacroIfs(code, reg = @@M_IF_SOME_HEAD)
		macroIfs = Array.new
		macroIf = extractMacroIf(code, 0, reg)

		if macroIf == nil
			return nil
		end

		while macroIf != nil
			macroIfs.push macroIf
			macroIf = extractMacroIf(code, macroIf.tail, reg)
		end
		
		return macroIfs
	end

	def extractFuncNames(code)
		code = removeComments(code)

		# remove keywords "#if xxx" and "#endif" to prevent from conflicting
		code.gsub!(@@MACRO_LINE, "")
		# remove "else if()"
		code.gsub!(@@ELSE_CODE, "")
		code.gsub!(@@EXTERN_LINE, "")

		# proto type declaration
		code.gsub!(Regexp.new(@@FUNCTION_DEF.to_s + "\\s*;"), "")

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


	def decode(code, noComment)
		if noComment == true
			code = removeComments(code)
		else
			code = removeCommentsContaining(code, @@FUNCTION_DEF)
		end

		decodeds = extractFunctions(code)
		decodeds.each{
			|d|
			if noComment == false
				d.comments = extractComments(d.body)
				d.body = removeComments(d.body)
			end
		}
	end

	def eachFunctions(code, noComment = true, &onEach)
		puts "-------------- eachFunctions --------------"
		functions = decode(code, noComment)
		for func in functions
			#puts func
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


