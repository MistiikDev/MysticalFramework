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

local PlayerFramework = {}
PlayerFramework.__index = PlayerFramework

local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local Run = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local Client = StarterPlayer.StarterPlayerScripts

local Modules = GameFolder.Modules
local Communications = GameFolder.Communication

local Classes = Modules.Classes
local Utilities = Modules.Utilities

local Remotes = Communications.Remotes

local Types = require(Utilities.Types)
local Promise = require(Utilities.Promise)
local Errors = require(GameFolder.Framework.Errors)

local ClientErrors = Errors.Client

--[[

	BUILDERS
	
]]--

function PlayerFramework.new()
	local self = {}

	self.Plugins = {}
	self.Classes = {}
	
	self.Threads = {}
	
	for Index, Class in pairs(Modules.Classes:GetChildren()) do
		if Class.ClassName == "ModuleScript" then
			local R_Class = require(Class)

			self.Classes[Class.Name] = {}
			self.Classes[Class.Name] = R_Class
		end
	end

	for Index, Plugin in pairs(Client.PlayerFramework:GetChildren()) do 
		if Plugin.ClassName == "ModuleScript" then
			local R_Plugin = require(Plugin)		

			self.Plugins[Plugin.Name] = {} 
			self.Plugins[Plugin.Name] = R_Plugin.new(setmetatable(self, PlayerFramework))
		end
	end

	for Name, Plugin in pairs(self.Plugins)  do
		if Plugin.Init then 
			Plugin:Init()
		else 
			ClientErrors.MissingItem("Init Function", Name)
		end
	end

	self:Init()

	return setmetatable(self, PlayerFramework)
end 

function PlayerFramework:Init()
	-- Get deps
	self.Input = self:Get("InputSystem")
	self.Camera = self:Get("Camera")
	self.Binds = self:Get("Binds")
	self.InteractionHandler = self:Get("InteractionHandler")
	
	self.Camera:SetOptions({}, true) -- Default options
	self.Camera:SetFPSMode() -- Set it for now
	
	-- Setup binds
	for Index, Bind in pairs(self.Binds:ReturnBindedEvents()) do 
		self.Input:NewInput(Bind)
	end
	
	-- Netcode setup
	self:BindEvents()
end

function PlayerFramework:BindEvents()
	-- All the remotes connections go here
end

function PlayerFramework:Step(deltaTime)
	for Name, Module in pairs(self.Plugins) do
		if Module.Step then 
			self.Threads[Name] = coroutine.wrap(function()
				Module:Step(deltaTime)
			end)
			
			self.Threads[Name](deltaTime)
		end
	end
end

--[[

	FUNCTIONS
	
]]--

function PlayerFramework:New(ClassName : string, ...)
	local Class = self.Classes[ClassName]
	
	return Class.new(self, ...)
end

function PlayerFramework:Get(PluginName : string, ...)
	local Plugin = self.Plugins[PluginName]
	
	if (Plugin ~= nil) then
		return Plugin
	end
	
	ClientErrors.IndexError(PluginName, "Plugin")
	
	return {}
end

--[[

	NETCODE
	
]]--

function PlayerFramework:FireServer(RemoteName : string, ...)
	local Args = {...}

	local RemoteFolders = Remotes.Events
	local Remote : RemoteEvent = RemoteFolders:FindFirstChild(RemoteName)
	
	if (Remote) then
		Remote:FireServer(Args)
	else 
		return ClientErrors.IndexError(RemoteName, "RemoteEvent")
	end
end

function PlayerFramework:InvokeServer(FunctionName : string, ...)
	local Args = {...}
	
	local FunctionsFolder = Remotes.Functions
	local Function : RemoteFunction = FunctionsFolder:FindFirstChild(FunctionName)
	
	if (Function) then 
		local Return = Function:InvokeServer(Args)
		
		if (Return) then
			return Return
		end
	else 
		return ClientErrors.IndexError(FunctionName, "RemoteFunction")
	end
end

function PlayerFramework:RegisterServerCall(RemoteName : string, PassedFunction)
	local Remote : RemoteEvent = Remotes.Events:FindFirstChild(RemoteName)

	if (Remote) then
		Remote.OnClientEvent:Connect(PassedFunction)
	end
end

function PlayerFramework:CutServerCall(RemoteName)
	if (RemoteName) then 
		if (self.Connections[RemoteName]) then 
			self.Connections[RemoteName]:Disconnect()
		end
	end
end


return PlayerFramework
