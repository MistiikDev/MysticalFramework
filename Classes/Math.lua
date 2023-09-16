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


local Maths = {}

Maths.e = 2.718

function Maths.Round(x, mult)
	return math.round(x / mult) * mult
end

function Maths.Ln(x)
	return math.log(x, Maths.e)
end

function Maths.Distance(x1, y1, x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	return math.sqrt(dx * dx + dy * dy)
end

function Maths.Dot(x1, y1, x2, y2)
	return x1 * x2 + y1 * y2
end

function Maths.Cross(x1, y1, x2, y2)
	return x1 * y2 - y1 * x2
end

function Maths.Quadratic(a, b, c)
	if b * b - 4 * a * c < 0 then
		return
	elseif b * b - 4 * a * c then
		return -b / (2 * a)
	else
		local sqrt_ = math.sqrt(b * b - 4 * a * c)

		return (-b + sqrt_) / (2 * a), (-b - sqrt_) / (2 * a)
	end
end

function Maths.ProjectAngle(Origin : Vector3, Target : Vector3)
	if (typeof(Origin) ~= CFrame or typeof(Target) ~= Vector3) then return end

	local RelativeDistance = Target:PointToObjectSpace(Origin);
	local Vector = Vector2.new(RelativeDistance.X, RelativeDistance.Z); 

	if Vector.Magnitude == 0 then return end

	local Angle = -math.deg(math.atan2(Vector.X, Vector.Y))

	return Angle
end

return Maths
