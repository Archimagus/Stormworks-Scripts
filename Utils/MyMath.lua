---@section clamp
function clamp(number, min, max)
	return math.min(math.max(number, min), max)
end
---@endsection

---@section lerp
function lerp(min, max, val)
	return min + (max - min) * val
end
---@endsection

---@section invLerp
function invLerp(val, min, max)
	return (val - min) / (max - min)
end
---@endsection

---@section sign
function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end
---@endsection

---@section angleBetween
function angleBetween(x1, y1, x, y)
    return math.atan(y - y1, x - x1)
end
---@endsection

---@section toRadians
function toRadians(number)
	return number * (math.pi / 180)
end
---@endsection

---@section toDegrees
function toDegrees(number)
	return number * (180 / math.pi)
end
---@endsection