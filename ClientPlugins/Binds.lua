--[[
	BSD 2-Clause Licence
	Copyright © 2023. All rights reserved.
    MistiikDev aka DAF aka Mistiik
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice, this
	   list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

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
