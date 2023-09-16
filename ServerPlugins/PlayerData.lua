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


local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(Framework)
	local self = {}
	
	self.Framework = Framework
	self.Players = {}
	
	setmetatable(self, PlayerData)
	
	return self
end

function PlayerData:AddPlayer(Player : Player)
	if not (Player) then return end
	
	self.Players[Player.UserId] = {}
end

function PlayerData:RemovePlayer(Player : Player)
	if not (Player) then return end
	
	self.Players[Player.UserId] = nil
end

function PlayerData:IsPlayerRegistered(Player : Player)
	return (self.Players[Player.UserId] and true or false)
end

function PlayerData:GetData(Player : Player, Entry : string, DefaultValue : any)
	if not (Player) then return end
	if not (Entry) then return end
	
	local EntryData = self.Players[Player.UserId][Entry]
	
	if (EntryData) then 
		return EntryData
	else 
		self.Players[Player.UserId][Entry] = DefaultValue
		
		return DefaultValue
	end
end

function PlayerData:SetData(Player : Player, Entry : string, Value : any)
	if not (Player) then return end
	if not (Entry) then return end

	local EntryData = self.Players[Player.UserId][Entry]

	if (EntryData) then 
		self.Players[Player.UserId][Entry] = Value
	end
end

return PlayerData
