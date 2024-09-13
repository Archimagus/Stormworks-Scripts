require("Autopilot.Autopilot")
ArchUtils = ArchUtils or {}

---@class PlaneController
---@field autopilot Autopilot
---@field physicsSensor PhysicsSensor
---@field pitchPID ArchPID
---@field rollPID ArchPID
---@field yawPID ArchPID
---@field maxPitch number
---@field maxRoll number
ArchUtils.PlaneController = {
    ---@param cls PlaneController
    ---@param autopilot Autopilot
    ---@param maxPitch number
    ---@param maxRoll number
    ---@return PlaneController
    new = function(cls, autopilot, maxPitch, maxRoll)
        local obj = LifeBoatAPI.lb_copy(cls, {
            autopilot = autopilot,
            physicsSensor = autopilot.physicsSensor,
            pitchPID = ArchUtils.ArchPID:new(0.5, 0.001, 0.01, -maxPitch, maxPitch),
            rollPID = ArchUtils.ArchPID:new(0.5, 0.001, 0.01, -maxRoll, maxRoll),
            maxPitch = maxPitch,
            maxRoll = maxRoll
        })
        return obj --[[@as PlaneController]]
    end,

    ---@param self PlaneController
    ---@param rollCommand number
    ---@param pitchCommand number
    ---@param yawCommand number
    ---@param goToDestination boolean
    ---@return table
    update = function(self, rollCommand, pitchCommand, yawCommand, goToDestination, destinationX, destinationY)
        local aileronOutput, elevatorOutput, rudderOutput = 0, 0, 0
        altitudeControl, headingControl = self.autopilot:update(goToDestination, destinationX, destinationY)

        pitchTarget = clamp(altitudeControl * self.maxPitch, -self.maxPitch, self.maxPitch)
        rollTarget = clamp(headingControl * self.maxRoll, -self.maxRoll, self.maxRoll)
        yawTarget = headingControl

        pitchTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(pitchTarget, -pitchCommand * self.maxPitch, math.abs(pitchCommand))
        rollTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(rollTarget, rollCommand * self.maxRoll, math.abs(rollCommand))
        yawTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(yawTarget, yawCommand, math.abs(yawCommand))

        if (math.abs(pitchCommand) > 0.01) then
            self.autopilot:setTargetAltitude(self.physicsSensor.altitude)
        end
        if (math.abs(rollCommand) > 0.01 or math.abs(yawCommand) > 0.01) then
            self.autopilot:setTargetHeading(self.physicsSensor.heading)
        end


        elevatorOutput = -self.pitchPID:update(self.physicsSensor.pitch, pitchTarget)
        aileronOutput = self.rollPID:update(self.physicsSensor.roll, rollTarget)
        rudderOutput = yawTarget

        return {
            aileron = aileronOutput,
            elevator = elevatorOutput,
            rudder = rudderOutput
        }
    end,

    ---@param self PlaneController
    ---@param altitude number
    setTargetAltitude = function(self, altitude)
        self.autopilot:setTargetAltitude(altitude)
    end,
}
