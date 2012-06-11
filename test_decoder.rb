
require "./decoder"

# test codes
def Decoder::test

	dec = Decoder.new()

	code = nil;


	open(ARGV[0]){
		|file|
		code = file.read
	}

	if code == nil
		raise "empty code"
	end

	puts code
	
	decoded = dec.extractMacroIf code, 0
	
#	puts dec.extractComments code
#	dec.removeComments code
	dec.extractFunctions code

end

Decoder::test

