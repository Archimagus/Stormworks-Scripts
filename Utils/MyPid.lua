require("Utils.MyMath")
require("LifeBoatAPI.Utils.LBCopy")

MyUtils = MyUtils or {}
---@section PID
---@class PID
---@field p number
---@field i number
---@field d number
---@field bias number fixed offset to apply to the output
---@field minOutput number min value of the output, if the output would be outside this value it prevents the integral from winding
---@field maxOutput number max value of the output, if the output would be outside this value it prevents the integral from winding
---@field error number last updates Proportional Error
---@field integral number the accumulated integral as of last update
---@field derivative number the derivative (slope) of the error as of last update
MyUtils.PID = {
	-- Constructor function for PID objects
	---@param p number
	---@param i number
	---@param d number
	---@param bias number fixed offset to apply to the output
	---@param minOutput number min value of the output, if the output would be outside this value it prevents the integral from winding
	---@param maxOutput number max value of the output, if the output would be outside this value it prevents the integral from winding
	---@return PID
	new = function(self, p, i, d, bias, minOutput, maxOutput)
		local newObj =
		{
			p = p,
			i = i,
			d = d,
			bias = bias,
			minOutput = minOutput or -9999,
			maxOutput = maxOutput or 9999,
			error = 0,
			integral = 0,
			derivative = 0,
		}
		return LifeBoatAPI.lb_copy(self, newObj)
	end,

	-- Method for updating a PID object
	---@param target number the target value we are trying to reach
	---@param process number the current value
	---@return number The new output value
	update = function(self, target, process)
		if setPid then setPid() end

		local e = target - process
		self.integral = self.integral + e
		self.derivative = e - self.error
		self.error = e

		local value_out = self.p * self.error + self.i * self.integral + self.d * self.derivative + self.bias

		if value_out > self.maxOutput or value_out < self.minOutput then
			self.integral = self.integral - self.error
		end

		value_out = clamp(value_out, self.minOutput, self.maxOutput)

		return value_out
	end,
	--- resets the internal counters
	reset = function(self)
		self.error = 0
		self.integral = 0
		self.derivative = 0
	end,
}
---@endsection
