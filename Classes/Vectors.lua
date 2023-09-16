local Vectors = {}

function Vectors.Dot(vec1, vec2)
	return math.clamp((vec1:Dot(vec2)), -1, 1)
end

function Vectors.GetAngleBetweenVectors(vec1, vec2)
	return math.acos(Vectors.Dot(vec1, vec2))
end

function Vectors.Reflect(v, n)
	local dotProduct = v:Dot(n)
	
	local reflection = Vector3.new(
		v.x - 2 * dotProduct * n.x,
		v.y - 2 * dotProduct * n.y,
		v.z - 2 * dotProduct * n.z
	)
	
	return reflection
end


return Vectors
