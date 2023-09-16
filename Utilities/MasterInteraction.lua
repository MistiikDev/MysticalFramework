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

local InteractibleMaster = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local IsServer = RunService:IsServer()

local InteractibleMaster = {}

InteractibleMaster.__index = function(self,Index)
	if rawget(InteractibleMaster,Index) then
		return InteractibleMaster[Index]
	elseif rawget(self,"_Inherited") and self._Inherited[Index] then
		return self._Inherited[Index]
	else
		return nil
	end
end

InteractibleMaster.__newindex = function(self,Index,Value)
	if self._Inherited and self._Inherited[Index] then
		self._Inherited[Index] = Value
	else
		rawset(self,Index,Value)
	end
end

InteractibleMaster.ClassName = "Superclass"
if InteractibleMaster.Superclass then setmetatable(InteractibleMaster, InteractibleMaster.Superclass) end

function InteractibleMaster.new(Framework, Data)
	local self = setmetatable({}, InteractibleMaster)

	if InteractibleMaster.Superclass and InteractibleMaster.Superclass.new then
		self._Inherited = InteractibleMaster.Superclass.new(Framework, Data)
	end

	self.Data = Data
	self.Framework = Framework
	self.Mesh = self.Data.Mesh

	self.Occupied = false
	self.Enabled = true

	self.PlayerUsing = nil	
	self.LeavingConnection = nil
	self.LeaveKeyCode = Enum.KeyCode.E

	self.Timeout = self.Data.Timeout or true
	self.MaxTimeAllowed = self.Data.TimeoutValue or 60
	self.SimpleInteraction = self.Data.SimpleInteraction or false

	self.LastEntered = tick()

	return self
end

function InteractibleMaster:MasterInit()
	if (not IsServer) then 
		self.Camera = self.Framework:Get("Camera")
		self.Character = self.Framework:Get("CharacterController")
		self.Inventory = self.Framework:Get("InventorySystem")
		self.UI = self.Framework:Get("UISystem")
		self.Input = self.Framework:Get("InputSystem")
		self.InteractionHandler = self.Framework:Get("InteractionHandler")

		task.spawn(function()
			while task.wait(1) do 
				if (tick() - self.LastEntered > self.MaxTimeAllowed) and self.Occupied and self.Data.IsClient then 
					self.InteractionHandler:InteractWithAsset(self.Mesh)
				end
			end
		end)
	else
		self.WorldInteractibles = self.Framework:Get("WorldInteractibles")
	end
end

function InteractibleMaster:MasterSetEnabled(Enabled)
	self.Enabled = Enabled
end

function InteractibleMaster:MasterElectricToggle(Operational, Callback)
	if (not IsServer) then 
		if (self.Occupied) then 
			self:ClientUse({false})
		end
	else
		if (self.PlayerUsing) then
			self:Use(self.PlayerUsing)
		end
	end

	self:SetEnabled(Operational)
end

function InteractibleMaster:MasterClientUse(...)
	if not self.Enabled then return end 
	
	local Accessing, AccessingCallback = nil

	if (...) then 
		Accessing, AccessingCallback = unpack(...)
	else 

		if not self.PlayerUsing then
			self.PlayerUsing = Players.LocalPlayer
		else 
			self.PlayerUsing = nil
		end

		Accessing = self.PlayerUsing and true or false
	end
	
	if AccessingCallback then
		AccessingCallback(Accessing)
	end
	
	self.Occupied = Accessing
	self.LastEntered = tick()

	-- Send info to other plugins.
	self.InteractionHandler:ToggleInteraction(not Accessing)
	self.Inventory:FreezeInventory(Accessing)
	self.Camera:ToggleTracking(not Accessing and "Lock" or "Free", not Accessing and self.Character.Character or (self.Mesh.CamPart))
	self.UI:ToggleExitUI(Accessing)
	self.Character:MakeCharacterTransparency(Accessing and 1)

	if (self.LeavingConnection) then self.LeavingConnection:Disconnect() end

	if (not Accessing) then		
		self.Character:EnableMouvment() 
		self.InteractionHandler:SetMouseMode("Default")
	else 
		self.LeavingConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
			if (input.KeyCode == self.LeaveKeyCode) then 
				self.InteractionHandler:InteractWithAsset(self.Mesh)
			end
		end)

		self.Character:DisableMouvment()
		self.InteractionHandler:SetMouseMode("Free")
	end
	
	return Accessing
end

function InteractibleMaster:MasterUse(Player)
	if not self.Enabled then return false end 

	local Char = Player.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local ID = self.Data.Mesh:GetAttribute("Identifier")

	if (Char) then
		local HRP = Char:WaitForChild("HumanoidRootPart")
		local ForwardPart = self.Data.Mesh:FindFirstChild("ForwardPart")		
		
		local LookingForward = false
		
		if ForwardPart then
			local Angle = HRP.CFrame.LookVector:Angle(ForwardPart.CFrame.LookVector)

			if (Angle < math.pi / 2) then 
				LookingForward = true
			end
		end 
		
		if not self.Data.StandaloneFromPlayer then
			if LookingForward then 
				if (not self.PlayerUsing) then 
					self.PlayerUsing = Player
					
					if self.Data.Mesh:FindFirstChild("PlayerPosition") then 
						Char:PivotTo(self.Data.Mesh.PlayerPosition.CFrame)
					end

					return {true, true}
				else 
					if (self.PlayerUsing == Player) then 
						self.PlayerUsing = nil

						return {true, false}
					end
				end
			end
		end

		return {true}
	end

	return {false}
end

return InteractibleMaster
