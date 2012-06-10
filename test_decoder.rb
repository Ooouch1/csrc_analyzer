
require "./decoder"

# test codes
def Decoder::test

	dec = Decoder.new()

	code = nil;


	open("test.c"){
		|file|
		code = file.read
	}
#	puts dec.extractComments code
	dec.removeComments code
	dec.extractFunctions code

end

Decoder::test

