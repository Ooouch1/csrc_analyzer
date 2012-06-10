
class DecodedFunction
	attr_accessor :name
	attr_accessor :body
	attr_accessor :comments

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
	# C-language definitions
	# extend this class to override them for other language

		@@LCOM_HEAD = "\/\/"
		@@LCOM_BODY ="[^\n]*"
		@@LCOM_TAIL = "\n"
		@@LINE_COMMENT = Regexp.new(@@LCOM_HEAD + @@LCOM_BODY + @@LCOM_TAIL)

		@@BCOM_HEAD = "\/\\*\/?"
		@@BCOM_BODY = "([^\/]|[^\\*]\/)*"
		@@BCOM_TAIL = "\\*\/"
		@@BLOCK_COMMENT = Regexp.new(@@BCOM_HEAD + @@BCOM_BODY + @@BCOM_TAIL)

		@@COMMENT = Regexp.union(@@LINE_COMMENT, @@BLOCK_COMMENT)
		@@FUNCTION_DEF = /((unsigned\s+|signed\s+)?\w+(\s+|\s*(\s*\*)+\s*)\w+\s*\([^\);]*\))/ # unsigned? type  name(signitures)



	def removeComments(code)
		removed = code.gsub(@@COMMENT, "")
		puts "-------- all comments are removed ------------"
		puts removed
		
		return removed
	end

	#requires escaped text if you want use "(", "*" and so on as a character
	def createCommentContaining(text)
	
		line = Regexp.new( @@LCOM_HEAD + @@LCOM_BODY + text.to_s() + @@LCOM_BODY + @@LCOM_TAIL )
		
		block = Regexp.new( @@BCOM_HEAD + @@BCOM_BODY + text.to_s + @@BCOM_BODY +@@BCOM_TAIL)

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

	# �Y���������ׂĂ̕������z��ŕԂ�
	def extractComments(code)
		comments = extractAll(code, @@COMMENT)
		puts "-------- comments ---------"
		p comments
		return comments
	end


	
	# assumes comments containing function def. are removed
	def extractFunction(code, name)
		require "./extracting"

		start = code.index(name)
		p start
		state = ExtractingBegin.new(start)

		# solve by state pattern
		while (not state.isEnd(code)) and (state.index < code.length) 
			state = state.extract(code)
		end

		func = code[start..state.index]

		decoded = DecodedFunction.new(name, removeComments(func), extractComments(func))

		puts "-------- Func ---------"
		puts decoded
		return decoded
	end


	def extractFunctions(code, names = nil)
	
		puts code
		if names == nil
			noFuncComment = removeCommentsContaining(code, @@FUNCTION_DEF)
			names = extractFuncNames( noFuncComment)
		end
		
		functions = Array.new()

		for name in names
			func = extractFunction(code, name)
			functions.push func
		end

		functions
	end

	# �R�����g�A�E�g����Ă��Ă��E���̂Œ���
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
		puts "-------- extract all ------"
		p reg

		match = reg.match(code) 

		while(match != nil)
			matched = match[0]
			found.push matched
			index = match.begin(0)
			match = reg.match(code, index + matched.length) 
		end
		return found
	end

end

dec = Decoder.new()

code = nil;


open("test.c"){
	|file|
	code = file.read
}

# test codes
#puts dec.extractComments code
#dec.removeComments code
#dec.extractFunctions code

