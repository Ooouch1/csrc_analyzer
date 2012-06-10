	class ExtractingState
		attr_reader :index
		@@vLCOM_HEAD_S = "//"
		@@vLCOM_TAIL_S = "\n"
		
		@@vBCOM_HEAD_S = "/*"
		@@vBCOM_TAIL_S = "*/"
		
		def initialize(index, depth = 0)
			@index = index
			@depth = depth
		end
		
		def isEnd(code)
			return @index >= code.length
		end
		
		def extract(code)
		end

		def isInCode(code, start, text)
			return start <= code.length - text.length 
		end
	
		def isOnText(code, start, text)
			if isInCode(code, start, text) == false
				return false
			end
			return code[start..(start + text.length - 1)] == text
		end

	end

	def ExtractingState::setLineComment(head, tail)
		@@vLCOM_HEAD_S = head
		@@vLCOM_TAIL_S = tail
	end
	
	def ExtractingState::setBlockComment(head, tail)
		@@vBCOM_HEAD_S = head
		@@vBCOM_TAIL_S = tail
	end
	
	class ExtractingBegin < ExtractingState
		def extract(code)
			return ExtractingCode.new(@index).extract(code)
		end
		def isEnd(code)
			return false
		end
		
	end

	class ExtractingEnd < ExtractingState
		def extract(code)
			return self
		end
		
		def isEnd(code)
			true
		end
	end

	class ExtractingBlockComment < ExtractingState
		def extract(code)
			#p "block " + @index.to_s
			if isOnText(code, @index, @@vBCOM_TAIL_S)
				@index += 1
				return ExtractingCode.new(@index, @depth)
			else 
				@index += 1
			end
			return self
		end
	end
	
	class ExtractingLineComment < ExtractingState

		def extract(code)
			#p "line" + @index.to_s
			c = code[@index]

			if isOnText(code, @index, @@vLCOM_TAIL_S)
				@index += 1
				return ExtractingCode.new(@index, @depth)
			else
				@index += 1
			end
			
			return self
		end

	end

	class ExtractingCode < ExtractingState

		def extract(code)
			
			if index >= code.length
				puts "length over"
				return ExtractingEnd.new(@index)
			end
			
			if isOnText(code, @index, @@vLCOM_HEAD_S)
				return ExtractingLineComment.new(@index + 1, @depth)

			elsif isOnText(code, @index, @@vBCOM_HEAD_S)
				return ExtractingBlockComment.new(@index + 1, @depth)
			end

			c = code[@index]
			@index += 1

			case c
			when '{'
				@depth += 1
			when '}' 
				@depth -= 1
				if @depth == 0
					puts "at the end of the function"
					return ExtractingEnd.new(@index, @depth) # reach the end of the function!
			end

			return self
		end
	end

