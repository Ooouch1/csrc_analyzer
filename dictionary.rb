
def loadDictionary
	dictionary = Hash.new  # hash of |group, keyword array||

	dictionary["loop"] =
	["for","while"]

	dictionary["condition"] =
	["if"]
	
	dictionary
end
