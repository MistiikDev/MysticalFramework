local Binds = {}
Binds.__index = Binds

function Binds.new(PF)
	local self = {}
	
	self.BindedEvents = {}
	self.PF = PF
	
	self.BindedEvents = {
		{
			"Sprint", Enum.KeyCode.LeftShift, function(actionName, inputState, _inputObject)
				if inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.End then 
					self.PF:Get("CharacterController"):Sprint()
				end
			end, false
		}, 
		{
			"Interaction", Enum.UserInputType.MouseButton1, function(actionName, inputState, _inputObject)			
				if (inputState == Enum.UserInputState.Begin) then 
					self.PF:Get("InteractionHandler"):InteractWithWorldAsset()
				end
			end, false
		},
		{
			"EquipItem", { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three }, function(actionName, inputState, _inputObject)
				if (inputState == Enum.UserInputState.Begin) then 
					self.PF:Get("InventorySystem"):EquipItem(_inputObject)
				end
			end, false
		},
		{
			"UseItem", Enum.UserInputType.MouseButton1, function(actionName, inputState, _inputObject)
				if (inputState == Enum.UserInputState.Begin) then 
					local IsItem = self.PF:Get("InteractionHandler"):CheckForInteractible()
					if (not IsItem) then 
						self.PF:Get("InventorySystem"):UseActiveItem()
					end
				end
			end, false
		},
	}
	
	setmetatable(self.BindedEvents, {
		__newindex = function(tbl, index, value)
			self.PF:Get("InputSystem"):NewInput(value)
		end,
	})
	
	return setmetatable(self, Binds)
end

function Binds:AddBind(Bind)
	self.BindedEvents[#self.BindedEvents + 1] = Bind
end

function Binds:GetBindByName(Name)
	local FoundBind = nil
	
	for Index, Bind in pairs(self.BindedEvents) do
		if (Bind[1]) == Name then
			FoundBind = Bind
			
			break
		end
	end
	
	return FoundBind
end

function Binds:ReturnBindedEvents()
	return self.BindedEvents
end

function Binds:Step()
	
end

return Binds
