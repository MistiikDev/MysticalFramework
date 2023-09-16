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

local ServerFramework = {}
ServerFramework.__index = ServerFramework

local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local Run = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Players = game:GetService("Players")

local Server = ServerScriptService.ServerFramework

local ServerGame = ServerStorage:WaitForChild("ServerGame")

local Modules = GameFolder.Modules
local Communications = GameFolder.Communication

local Classes = Modules.Classes
local Utilities = Modules.Utilities

local Bindables = Communications.Bindables
local Remotes = Communications.Remotes

local Types = require(Utilities.Types)
local Promise = require(Utilities.Promise)
local Errors = require(GameFolder.Framework.Errors)

local ClientErrors = Errors.Server

--[[

	BUILDERS
	
]]--

function ServerFramework.new()
	local self = {}

	self.Plugins = {}
	self.Classes = {}
	
	self.Connections = {}
	
	for Index, Class in pairs(Modules.Classes:GetChildren()) do
		if Class.ClassName == "ModuleScript" then
			local R_Class = require(Class)

			self.Classes[Class.Name] = {}
			self.Classes[Class.Name] = R_Class
		end
	end

	for Index, Plugin in pairs(Server:GetChildren()) do 
		if Plugin.ClassName == "ModuleScript" then
			local R_Plugin = require(Plugin)

			self.Plugins[Plugin.Name] = {}
			self.Plugins[Plugin.Name] = R_Plugin.new(setmetatable(self, ServerFramework))
		end
	end

	for Index, Plugin in pairs(self.Plugins) do
		if Plugin.Init then 
			Plugin:Init()
		else 
			warn("No dependecies set for plugin : ", Index)
		end
	end
	
	setmetatable(self, ServerFramework)
	
	self:Init()

	return setmetatable(self, ServerFramework)
end 

function ServerFramework:Init()
	self.PlayerData = self:Get("PlayerData")
	self:BindEvents()
	
	Players.PlayerAdded:Connect(function(Player)
		self:RegisterPlayer(Player)
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		self:ForgetPlayer(Player)
	end)
end

function ServerFramework:RegisterPlayer(Player)
	self.PlayerData:AddPlayer(Player)
end

function ServerFramework:ForgetPlayer(Player)
	self.PlayerData:RemovePlayer(Player)
end

function ServerFramework:BindEvents()
	self:RegisterClientFunction("GetItemData", function(Player : Player, Args)
		if (Player) then 
			local ItemString = unpack(Args)
			local ItemData = Modules.ItemData:FindFirstChild(ItemString)
			
			if ItemData then 
				return ItemData:Clone()
			end
			
			return error("No Item Data for : "..ItemString.." was found!")
		end
	end)
end

function ServerFramework:Step(...)
	for Name, Module in pairs(self.Plugins) do
		if Module.Step then 
			Module:Step(...) 
		end
	end
end

--[[

	Framework Functions
	
]]--

function ServerFramework:New(ClassName : string, ...)
	local Class = self.Classes[ClassName]
	
	return Class.new(ServerFramework, ...)
end

function ServerFramework:Get(PluginName : string, ...)
	local Plugin = self.Plugins[PluginName]
	
	if (Plugin ~= nil) then
		return Plugin
	end
	
	warn("Did not find plugin : ", PluginName)
	
	return {}
end

--[[

	NETCODE
	
]]--

function ServerFramework:Fire(BindableName : string, ...)
	local Bindable : BindableEvent = Bindables.Events:FindFirstChild(BindableName)
	local Args = {...}
	
	if (Bindable) then 
		Bindable:Fire(Args)
	end
end

function ServerFramework:RegisterCall(BindableName : string, PassedFunction : () -> any) 
	local Bindable : BindableEvent = Bindables.Events:FindFirstChild(BindableName)
	
	if (Bindable) then 
		self.Connections[BindableName] = Bindable.Event:Connect(PassedFunction)
	end
end

function ServerFramework:CutCall(BindableName : string)
	if BindableName then 
		if self.Connections[BindableName] then 
			self.Connections[BindableName]:Disconnect()
		end
	end
end

function ServerFramework:FireClient(RemoteName : string, Player: Player, ...)
	local Remote : RemoteEvent = Remotes.Events:FindFirstChild(RemoteName)
	local Args = {...}
	
	if (Remote) then
		Remote:FireClient(Player, Args)
	end
end

function ServerFramework:FireAllClients(RemoteName : string, IgnorePlayers : {Player : Player}, ...)
	local Remote : RemoteEvent = Remotes.Events:FindFirstChild(RemoteName)
	local Args = {...}
	
	IgnorePlayers = IgnorePlayers or {}
	
	if (Remote) then
		for Index, Player in pairs(Players:GetPlayers()) do 
			if table.find(IgnorePlayers, Player) then 
				continue
			end
			
			Remote:FireClient(Player, Args)
		end
	end
end

function ServerFramework:RegisterClientCall(RemoteName: string, PassedFunction  : () -> any)	
	local Remote : RemoteEvent = Remotes.Events:FindFirstChild(RemoteName)	
	
	if (Remote) then
		self.Connections[RemoteName] = Remote.OnServerEvent:Connect(PassedFunction)
	end
end

function ServerFramework:RegisterClientFunction(RemoteName: string, PassedFunction  : () -> any)
	local Remote : RemoteFunction = Remotes.Functions:FindFirstChild(RemoteName)
	
	if (Remote) then
		Remote.OnServerInvoke = PassedFunction
	end
end

function ServerFramework:CutClientCall(RemoteName: string)
	if RemoteName then
		if (self.Connections[RemoteName]) then 
			self.Connections[RemoteName]:Disconnect()
		end
	end
end

return ServerFramework
