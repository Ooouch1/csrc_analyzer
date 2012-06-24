$LOAD_PATH << File.dirname(__FILE__)
	# C-language definitions
	# change them for other language

		@@LCOM_HEAD_S = "\/\/"
		@@LCOM_BODY_S ="[^\n]*"
		@@LCOM_TAIL_S = "\n"
		
		@@LCOM_HEAD = Regexp.new(@@LCOM_HEAD_S)
		@@LCOM_BODY = Regexp.new(@@LCOM_BODY_S)
		@@LCOM_TAIL = Regexp.new(@@LCOM_TAIL_S)
		
		@@LINE_COMMENT = Regexp.new(@@LCOM_HEAD_S + @@LCOM_BODY_S + @@LCOM_TAIL_S)

		@@BCOM_HEAD_S = "\/\\*\/?"
		@@BCOM_BODY_S = "([^\/]|[^\\*]\/)*"
		@@BCOM_TAIL_S = "\\*\/"

		@@BCOM_HEAD = Regexp.new(@@BCOM_HEAD_S)
		@@BCOM_BODY = Regexp.new(@@BCOM_BODY_S)
		@@BCOM_TAIL = Regexp.new(@@BCOM_TAIL_S)

		@@BLOCK_COMMENT = Regexp.new(@@BCOM_HEAD_S + @@BCOM_BODY_S + @@BCOM_TAIL_S)

		@@COMMENT = Regexp.union(@@LINE_COMMENT, @@BLOCK_COMMENT)


		# This definition catches wrong pattern like
		# "#if defined (xxx)",
		# "else if(xxxx)",
		# "extern func()"
		@@FUNCTION_DEF = /((unsigned\s+|signed\s+)?\w+(\s+|\s*(\s*\*)+\s*)\w+\s*\([^\);]*\))/ # unsigned? type(ex: int, int**)  name(signitures)
		@@ELSE_CODE = /else\s+\w+\s*\(.*\)/

		@@MACRO_LINE = /#[^\n]+/
		@@M_IF_LINE = /#if[^\n]+/
		
		@@M_IF_HEAD = /#(((if)(\s+defined)?)|ifdef|ifndef)/
		@@M_ELSE    = /#(else|(elif(\s+defined)?)(\s+\w+|\s*\(\s*\w+\s*\)))/
		@@M_IF_TAIL = /#endif/
		
		@@M_IF_HEAD_S = @@M_IF_HEAD.to_s
		
		@@M_IF_NOZERO_HEAD = /#((if|ifdef|ifndef)\s+([^0\s]|\w{2,}))\s/
		@@M_IF_ZERO_HEAD = /#if\s+0/

		@@M_IF_SOME_HEAD = /#(((if(\s+defined)?)|ifdef|ifndef)(\s+\w+|\s*\(\s*\w+\s*\)))\s/
		
		@@CODE_HEAD = Regexp.new("{")
		@@CODE_TAIL = Regexp.new("}")
		
		@@EXTERN = /extern/
		@@EXTERN_LINE = /extern\s+[^\n]+\n/
