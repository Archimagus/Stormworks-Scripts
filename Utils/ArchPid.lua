---@section ARCHPIDBOILERPLATE
--- Author: Archimagus
--- A simple PID controller for use in various projects.
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
---@endsection



require('LifeBoatAPI.Utils.LBCopy')
require('Utils.MyMath')

---@section ArchPID 1 ARCHPIDCLASS

---@class ArchPID
---@field P number
---@field I number
---@field D number
---@field setpoint number
---@field min number
---@field max number
---@field bias number
---@field error number
---@field integral number
---@field derivative number
---@field previousError number
---@field internalTarget number
ArchPID = {
    ---@param self ArchPID
    ---@param P number
    ---@param I number
    ---@param D number
    ---@param min number
    ---@param max number
    ---@param bias number | nil
    ---@return ArchPID
    new = function(self, P, I, D, min, max, bias)
        local obj = LifeBoatAPI.lb_copy(self, {
            P = P,
            I = I,
            D = D,
            min = min,
            max = max,
            bias = bias or 0,
            error = 0,
            integral = 0,
            derivative = 0,
            previousError = 0,
            output = 0,
            internalTarget = 0,
        })
        return obj --[[@as ArchPID]]
    end,

    ---@param self ArchPID
    ---@param target number
    ---@param process number
    ---@return number
    update = function(self, target, process)
        self.error = target - process
        local derivative = (self.error - self.previousError) / deltaTime
        local output = self.P * self.error + self.I * self.integral + self.D * derivative + self.bias
        
        self.previousError = self.error
        local integralDerivativeMultiplier = clamp(5-math.abs(derivative), 0, 5)/5
        if output < self.max and output > self.min then
            self.integral = self.integral + self.error * deltaTime * integralDerivativeMultiplier

        end
        local targetChange = self.internalTarget - target
        if targetChange > self.internalTarget * 0.1 
        or targetChange < -self.internalTarget * 0.1 then
            self.integral = 0
        end
        self.derivative = derivative
        self.internalTarget = target
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
