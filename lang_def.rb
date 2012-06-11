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
		@@FUNCTION_DEF = /((unsigned\s+|signed\s+)?\w+(\s+|\s*(\s*\*)+\s*)\w+\s*\([^\);]*\))/ # unsigned? type(ex: int, int**)  name(signitures)
		
		
		@@M_IF_NOZERO_HEAD = /#((if|ifdef|ifndef)\s+([^0\s]|\w{2,})\s)/
		@@M_IF_ZERO_HEAD = /#if\s+0\s+/
		@@M_IF_SOME_HEAD = /#(if|ifdef|ifndef)\s+\w+\s/
		@@M_IF_HEAD = /#(if|ifdef|ifndef)/
		@@M_IF_TAIL = /#endif/
		
		@@CODE_HEAD = Regexp.new("{")
		@@CODE_TAIL = Regexp.new("}")
