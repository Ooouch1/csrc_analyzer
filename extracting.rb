	class ExtractingState
		require "./lang_def"

		attr_reader :index
	  
		def initialize(index, depth = 0)
			@index = index
			@depth = depth
		end
		
		def isEnd(code)
			return @index >= code.length
		end
		
		def goNext(code)
		end
		def extract(code)
		end

		def overLength?(code, start, text)
			return start + text.length >= code.length 
		end
	
		def isOnText(code, start, text)
			reg = nil
			tail = start
			if text.class == String
				if overLength?(code, start, text)
					return false
				end
				reg = Regexp.new(Regexp.escape(text))
			else
				reg = text
			end

			result = code.match(reg, start)
			if result != nil
				if result.begin(0) == start 
					return true
				end
			end
			
			return false
		end

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
			if isOnText(code, @index, @@BCOM_TAIL)
				return ExtractingCode.new(@index + 2, @depth)
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

			if isOnText(code, @index, @@LCOM_TAIL)
				@index += 1
				return ExtractingCode.new(@index, @depth)
			else
				@index += 1
			end
			
			return self
		end

	end


	class ExtractingPair < ExtractingState
		attr_reader :vHEAD
		attr_reader :vTAIL
				
		def setSeparator(head, tail)
			@vHEAD = head
			@vTAIL = tail
		end
		
		def goNext(code, state_class = ExtractingEnd)
			if isOnText(code, @index, @vHEAD)
				@depth += 1
			elsif isOnText(code, @index, @vTAIL)
				@depth -= 1
				if @depth == 0
					puts "at the end of the pair"
					return state_class.new(@index + code.match(@vTAIL, @index)[0].length, @depth) # reach the end of the function!
				end
			end

			@index += 1
			return self
		end
		
		def extract(code)

			if index >= code.length
				puts "length over"
				return ExtractingEnd.new(@index)
			end

			# keep going!
			goNext(code)
		end

	end
	
	class ExtractingCode < ExtractingPair

		def initialize(index, depth = 0)
			super(index, depth)
			setSeparator @@CODE_HEAD, @@CODE_TAIL
		end

		def extract(code)

			# condtions to go to other action

			if index >= code.length
				raise "length over"
				return ExtractingEnd.new(@index)
			end

			if isOnText(code, @index, @@M_IF_HEAD)
				return ExtractingMacroIf.new(@index + 1, @depth)
			end
			
			if isOnText(code, @index, @@LCOM_HEAD)
				return ExtractingLineComment.new(@index + 1, @depth)
			end
			
			if isOnText(code, @index, @@BCOM_HEAD)
					return ExtractingBlockComment.new(@index + 1, @depth)
			end

			# keep going!
			goNext(code)
		end

	end


	# for the case of comment out by "#if"
	class ExtractingMacroIf < ExtractingPair
		
		def initialize(index, depth = 0)
			super(index, depth)
			setSeparator @@M_IF_HEAD, @@M_IF_TAIL
			p @vHEAD, @vTAIL
		end
		
		def extract(code)
			
			# imcompatible but faster
#			if code[@index] != "#"
#				@index += 1
#				return self
#			end
			
			if index >= code.length
				raise "length over"
				return ExtractingEnd.new(@index)
			end
						
			goNext(code, ExtractingCode)
		end

	end
