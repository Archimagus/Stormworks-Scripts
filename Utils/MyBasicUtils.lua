---@section Pulse
Pulse = {}

function Pulse:new()
	local newObj =
	{
		value = false,
		last_value = false
	}

	self.__index = self
	self.__call = function(self, value)
		local v = self.last_value
		self.last_value = value
		return value and not v
	end
	return setmetatable(newObj, self)
end

---@endsection
