
require "./lang_def"

code = "#if 0\n for(;;){} #endif"

puts (@@M_IF_SOME_HEAD.match(code) != nil)
puts (@@M_IF_TAIL.match(code) != nil)

code = File.read "test_if.c"

puts (@@M_IF_SOME_HEAD.match(code,0) != nil)
puts (@@M_IF_TAIL.match(code,0) != nil)

