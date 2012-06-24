$LOAD_PATH << File.dirname(File::expand_path(__FILE__))


	class ExtractingState
		require "lang_def"

		attr_reader :context
	  
		def initialize(context)
			@context = context
		end
		
		def index()
			return @context.index
		end
		
		def isEnd(code)
			return @context.index >= code.length
		end
		
		def createNextState(code)
		end

		def extract(code)
		end

		def findIndex(code, reg, context)
			index = code.index(reg, context.index)
			if index == nil
				index = context.index + 1
			end
			
			index
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

	class Context
		attr_accessor :depth
		attr_accessor :index
	
		CODE = 0
		M_IF = 1
		
		def initialize(index = 0)
			@depth = Array.new(2, 0) # array[type]-> depth
			@index = index
		end
		
		
	
	end


	class ExtractingBegin < ExtractingState
		def extract(code)
			return ExtractingCode.new(@context).extract(code)
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
			@context.index += 1

			if isOnText(code, @context.index, @@BCOM_TAIL)
				return ExtractingCode.new(@context)
			end
			return self
		end
	end
	
	class ExtractingLineComment < ExtractingState

		def extract(code)
			#p "line" + @index.to_s
			matched = code.match(@@LCOM_TAIL, @context.index)

			if matched == nil
				@context.index = code.length
			else
				@context.index = matched.begin(0)
			end
			
			return ExtractingCode.new(@context)
		end

	end


	class ExtractingPair < ExtractingState
		attr_reader :vHEAD
		attr_reader :vTAIL
		attr_reader :type
		
		@type = nil
		
		def initialize(context, type = Context::CODE)
			super(context)
			@type = type
		end
		
		def setSeparator(head, tail)
			@vHEAD = head
			@vTAIL = tail
		end
		
		def createNextState(code, type, next_class = ExtractingEnd)
			c = @context
			
			if isOnText(code, c.index, @vHEAD)
				c.depth[type] += 1

			elsif isOnText(code, c.index, @vTAIL)
				c.depth[type] -= 1

				if c.depth[type] == 0
					puts "at the end of the pair"
					c.index += code.match(@vTAIL, c.index)[0].length # skip keyword string
					return next_class.new(c) # reach the end of the function!
				end

			end

			c.index += 1
			return self
		end
		
		def extract(code)

			if index >= code.length
				puts "length over"
				return ExtractingEnd.new(@context)
			end

			# keep going!
			createNextState(code, type)
		end

	end
	
	class ExtractingCode < ExtractingPair

		def initialize(context)
			super(context, Context::CODE)
			setSeparator @@CODE_HEAD, @@CODE_TAIL
		end

		def extract(code)

#			@context.index = findIndex(code, /^\s/, @context)

			# condtions to go to other action
			c = @context
			if c.index >= code.length
				raise "length over"
				return ExtractingEnd.new(c)
			end

			if code[c.index] == "#"
				if isOnText(code, c.index, @@M_IF_HEAD)
					return SkippingMacroIf.new(c)
				end
			end
			
			if code[c.index] == "/"
				if isOnText(code, c.index, @@LCOM_HEAD)
					return ExtractingLineComment.new(c)
				end
			
				if isOnText(code, c.index, @@BCOM_HEAD)
						return ExtractingBlockComment.new(c)
				end
			end
			
			# keep going!
			createNextState(code, @type)
		end

	end


	# for extracting an area of "#if"
	class ExtractingMacroIf < ExtractingPair
		
		def initialize(context)
			super(context, Context::M_IF)
			setSeparator @@M_IF_HEAD, @@M_IF_TAIL
			p @vHEAD, @vTAIL
		end
		
		def extract(code)
			
			# imcompatible among language but fast
			@context.index = findIndex(code, "#", @context)
			
#			if index >= code.length
#				raise "length over"
#				return ExtractingEnd.new(@index)
#			end
#						
			createNextState(code, @type)
		end

	end


	class SkippingMacroIf < ExtractingMacroIf
		def extract(code)
			
			@context.index = findIndex(code, "#", @context)
			
			createNextState(code, @type, ExtractingCode)
			
		end
	end
