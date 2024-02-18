---@section ArchPulse
require("LifeBoatAPI.Utils.LBCopy")
ArchPulse = {
	new = function(self)
		return LifeBoatAPI.lb_copy(self, {
			value = false,
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

---@section ArchRampNumber
---@param value number The current value.
---@param up boolean Whether the value should be increased.
---@param down boolean Whether the value should be decreased.
---@param acceleration number|nil The acceleration of the value change. Defaults to 0.01.
---@param holdOnRelease boolean|undefined True to hold the value when neither up nor down are true. Otherwise, the value will be set to 0.
function ArchRampNumber(value, up, down, acceleration, holdOnRelease)
	acceleration = acceleration or 0.01
	return up and math.min(value + acceleration, 1) or down and math.max(value - acceleration, -1) or
	holdOnRelease and value or 0
end

---@endsection
