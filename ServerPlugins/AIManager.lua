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

local AIManager = {}
AIManager.__index = AIManager

local Tags = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
function AIManager.new(Framework)
	local self = {}

	self.Framework = Framework
	self.RegisteredAIs = {}
	self.ElectricityActive = true
	
	self.AIThreads = {}
	
	self.Algorithms = require(script.Pathfinder)
	
	setmetatable(self, AIManager)

	return self
end

function AIManager:Init()
	for Index, AI in pairs(Tags:GetTagged("AI")) do 
		if (AI:IsA("Model")) then 
			local Identifier = HttpService:GenerateGUID(true)
			
			local Animations = AI:FindFirstChild("Animations")
			local AnimationController = AI:FindFirstChildWhichIsA("AnimationController")
			local InitialPoses = AI:FindFirstChild("InitialPoses")
			local Config = AI:FindFirstChild("AIConfig")
			
			local Humanoid = AI:FindFirstChildWhichIsA("Humanoid")
			
			self.RegisteredAIs[Identifier] = {
				Animations = Animations,
				AnimationController = AnimationController,
				
				Mesh = AI,
				Poses = InitialPoses,
				Config = Config,
				
				Humanoid = Humanoid,
				
				Id = Identifier,
				
				Enabled = false,
				LoadedAnimations = {
					
				},
			}
			
			self.RegisteredAIs[Identifier].Load = function()
				for Index, Animation in pairs(self.RegisteredAIs[Identifier].Animations:GetChildren()) do 
					if (AnimationController and Animation) then
						self.RegisteredAIs[Identifier].LoadedAnimations[Animation.Name] = self.RegisteredAIs[Identifier].AnimationController:LoadAnimation(Animation)
					end
				end
								
				return self.RegisteredAIs[Identifier].LoadedAnimations
			end

			AI:SetAttribute("Identifier", self.RegisteredAIs[Identifier].Id)
		end
	end
	
	for Identifier, AISingleton in pairs(self.RegisteredAIs) do 		
		self:LoadAIAnimation(AISingleton.Id or Identifier)
		self:LoadPathfinding(AISingleton.Id or Identifier)
	end
end

function AIManager:LoadPathfinding(Id)
	if not self.RegisteredAIs[Id] then return end
	
	local AIThread = self.AIThreads[Id]
	
	if not self.AIThreads[Id] then 
		self.AIThreads[Id] = coroutine.create(function()
			self.Algorithms.Default(self, Id)
		end)
	end
	
	coroutine.resume(self.AIThreads[Id])
end

function AIManager:SuspendPathfinder(Id)
	if not self.RegisteredAIs[Id] then return end
	
	local AIThread = self.AIThreads[Id]
	
	if AIThread then
		coroutine.close(self.AIThreads[Id])
		
		self.AIThreads[Id] = nil
	end
end

function AIManager:PlayAnimation(Id, AnimationName)
	local AI = 	self.RegisteredAIs[Id]

	if not AI then return end
	if not AI.LoadedAnimations[AnimationName] then return end 
	
	local track = AI.LoadedAnimations[AnimationName]:Play()

	return track
end

function AIManager:LoadAIAnimation(Id)
	local AI = 	self.RegisteredAIs[Id]

	if not AI then return end
	if not AI.Load then return end 

	return AI.Load()
end

return AIManager
