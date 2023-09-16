local Timeline = {}
Timeline.__index = Timeline

local RS = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")


local Types = require(RS.Modules.Utilities.Types)
local Lerps = require(RS.Modules.Utilities.Lerp)
local Signal = require(script.Parent.Signal)

local DefaultOptions : Types.TimelineOptions = {
	Name = "DefaultTrack" ,
	VarType = 1
}

function Timeline.new(PF, Track : Types.Track, Options : Types.TimelineOptions)
	local self = {}
	
	self.VariableTrack = 0
	self.Track = Track -- {{Time, Value}, {Time, Value}...}
	self.Options = Options ~= nil and Options or DefaultOptions
	self.UpdateSignal = Signal.new()
	self.EndedSignal = Signal.new()
		
	return setmetatable(self, Timeline)
end

function Timeline:Play(TrackID : number, StartingTime)
	local RunConnection = nil
	
	local RunTime = StartingTime ~= nil and StartingTime or 0
	local EndTime = self.Track[#self.Track][1]
	local KeyframeIndex = 1
	
	RunConnection = Run.Heartbeat:Connect(function(DeltaTime)
		RunTime += DeltaTime
	
		while KeyframeIndex < #self.Track and RunTime >= self.Track[KeyframeIndex + 1][1] do
			KeyframeIndex += 1
		end

		-- Interpolate between the two keyframes
		local StartFrame = self.Track[KeyframeIndex]
		local NextFrame = self.Track[KeyframeIndex + 1]
		
		if NextFrame then
			local InterpolationFactor = (RunTime - StartFrame[1]) / (NextFrame[1] - StartFrame[1])
			local InterpolatedValue = nil

			if typeof(self.Options.VarType) == "number" then 
				InterpolatedValue = Lerps.IntLerp(StartFrame[2], NextFrame[2], InterpolationFactor)
			elseif typeof(self.Options.VarType) == "CFrame" then 
				InterpolatedValue = Lerps.CFrameLerp(StartFrame[2], NextFrame[2], InterpolationFactor)
			elseif typeof(self.Options.VarType) == "Vector3" or typeof(self.Options.VarType) == "Vector2" then 
				InterpolatedValue = Lerps.VectorLerp(StartFrame[2], NextFrame[2], InterpolationFactor)
			else 
				error(("Tried to lerp value of type : %s"):format(typeof(self.Options.VarType)))
			end

			self.UpdateSignal:Fire(TrackID, InterpolatedValue)
		end
		
		if RunTime >= EndTime then 
			self.EndedSignal:Fire(TrackID)

			RunTime = EndTime
			RunConnection:Disconnect()
		end	
	end)
end

return Timeline 
