-- ArchPID.lua
require("Utils.ArchIo")
require("Utils.ArchUtils")

---@section ArchPID 1 ARCHPIDCLASS
local dt = 1 / 60
---@class ArchPID
---@field P number
---@field I number
---@field D number
---@field setpoint number
---@field min number
---@field max number
---@field error number
---@field integral number
---@field derivative number
---@field previousError number
ArchUtils.ArchPID = {
    ---@param self ArchPID
    ---@param P number
    ---@param I number
    ---@param D number
    ---@param min number
    ---@param max number
    ---@return ArchPID
    new = function(self, P, I, D, min, max)
        local obj = LifeBoatAPI.lb_copy(self, {
            P = P,
            I = I,
            D = D,
            min = min,
            max = max,
            error = 0,
            integral = 0,
            derivative = 0,
            previousError = 0,
            output = 0,
        })
        return obj --[[@as ArchPID]]
    end,

    ---@param self ArchPID
    ---@param target number
    ---@param process number
    ---@return number
    update = function(self, target, process)
        self.error = target - process
        self.derivative = (self.error - self.previousError) / dt
        local output = self.P * self.error + self.I * self.integral + self.D * self.derivative
        self.previousError = self.error
        if output < self.max and output > self.min then
            self.integral = self.integral + self.error * dt
        end
        return clamp(output, self.min, self.max)
    end,
    ---@section reset
    reset = function(self)
		self.error = 0
		self.integral = 0
		self.derivative = 0
	end,
    ---@endsection
}
---@endsection ARCHPIDCLASS
