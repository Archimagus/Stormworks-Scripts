---@section clamp
function clamp(number, min, max)
	return math.min(math.max(number, min), max);
end
---@endsection`

---@section lerp
function lerp(a, b, t)
	return a + (b - a) * t
end
---@endsection`

---@section sign
function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end
---@endsection`