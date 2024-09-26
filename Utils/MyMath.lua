---@section MYMATHBOILERPLATE
-- Author: Archimagus
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
---@endsection

---@section deltaTime
deltaTime = 1 / 60
---@endsection

---@section clamp
-- Clamp a number between a minimum and maximum value (0-1) by default.
---@param number number The number to clamp.
---@param min number|nil The minimum value.
---@param max number|nil The maximum value.
---@return number The clamped number.
function clamp(number, min, max)
	min = min or 0
	max = max or 1
	return math.min(math.max(number, min), max)
end

---@endsection

---@section lerp
function lerp(min, max, val)
	return min + (max - min) * val
end

---@endsection

---@section easeInCubic
---Easing function that curves the value in a cubic fashion
---@param x number
---@return number
function easeInCubic(x)
	return x * x * x;
end

---@endsection

---@section easeInCircular
---Easing function that curves the value in a circular fashion
---@param x number
---@return number
function easeInCircular(x)
	return 1 - math.sqrt(1 - x * x);
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
