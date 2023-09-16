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
