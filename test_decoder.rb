$LOAD_PATH << File.dirname(__FILE__)

require "decoder"

# test codes

	code = nil;


	open(ARGV[0]){
		|file|
		code = file.read
	}

	if code == nil
		raise "empty code"
	end


decoder = Decoder.new

puts decoder.decode(code, false)

