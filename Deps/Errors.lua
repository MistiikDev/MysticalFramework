local TEMPLATE = ""

return {
	Client = {
		["IndexError"] = function(item : string, typeItem : string)
			return warn(TEMPLATE .. ("No %s such as %s was found!"):format(typeItem, item)) 
		end,
		["NoDepsForPlugin"] = function(Plugin : string)
			return warn(TEMPLATE .. ("No dependencies for %s were specified, make sure to initialize your plugins with necessary dependecies if you have to!"):format(Plugin)) 
		end,
		["MissingItem"] = function(item : string, storage : string)
			return warn(TEMPLATE .. ("Could not find : %s inside %s"):format(item, storage))
		end,
	}, 
	Server = {
		["IndexError"] = function(item : string, typeItem : string)
			return warn(TEMPLATE .. ("No %s such as %s was found!"):format(typeItem, item)) 
		end,
		["NoDepsForPlugin"] = function(Plugin : string)
			return warn(TEMPLATE .. ("No dependencies for %s were specified, make sure to initialize your plugins with necessary dependecies if you have to!"):format(Plugin)) 
		end,
		["MissingItem"] = function(item : string, storage : string)
			return warn(TEMPLATE .. ("Could not find : %s inside %s"):format(item, storage))
		end,
	}
}
