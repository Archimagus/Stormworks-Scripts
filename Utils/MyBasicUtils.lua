require("LifeBoatAPI.Utils.LBCopy")

---@section ArchPulse
---@class ArchPulse Pulse a boolean for a single frame.
ArchPulse = {
	new = function(self)
		return LifeBoatAPI.lb_copy(self, {
			last_value = false
		})
	end,
	check = function(self, value)
		local v = self.last_value
		self.last_value = value
		return value and not v
	end,
}

---@endsection

---@section ArchToggle
---@class ArchToggle Push to toggle a boolean value.
ArchToggle = {
	new = function(self, initial)
		return LifeBoatAPI.lb_copy(self, {
			value = initial,
			last_input = false
		})
	end,
	--- Check if the input has become true this frame and toggle the value if it has
	--- @param self ArchToggle
	--- @param input boolean The input to check.
	--- @return boolean The current value.
	check = function(self, input)
		local i = self.last_input
		self.last_input = input
		if input and not i then
			self.value = not self.value
		end
		return self.value
	end,
}
---@endsection

---@section ArchRampNumber
---@param value number The current value.
---@param up boolean Whether the value should be increased.
---@param down boolean Whether the value should be decreased.
---@param acceleration number|nil The acceleration of the value change. Defaults to 0.01.
---@param holdOnRelease boolean|nil True to hold the value when neither up nor down are true. Otherwise, the value will be set to 0.
function ArchRampNumber(value, up, down, acceleration, holdOnRelease)
	acceleration = acceleration or 0.01
	return up and math.min(value + acceleration, 1) or down and math.max(value - acceleration, -1) or
		holdOnRelease and value or 0
end

---@endsection
