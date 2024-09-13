ArchUtils = ArchUtils or {}

---@class HelicopterController
---@field physicsSensor PhysicsSensor
---@field autopilot Autopilot
---@field pitchPID ArchPID
---@field rollPID ArchPID
---@field maxPitch number
---@field maxRoll number
---@field internalTargetX number
---@field internalTargetY number
---@field goingToDestination boolean
ArchUtils.HelicopterController = {
    ---@param cls HelicopterController
    ---@param autopilot Autopilot
    ---@param maxPitch number
    ---@param maxRoll number
    ---@return HelicopterController
    new = function(cls, autopilot, maxPitch, maxRoll)
        local obj = LifeBoatAPI.lb_copy(cls, {
            physicsSensor = autopilot.physicsSensor,
            autopilot = autopilot,
            pitchPID = ArchUtils.ArchPID:new(0.5, 0.1, 0.1, -1, 1),
            rollPID = ArchUtils.ArchPID:new(0.5, 0.1, 0.1, -1, 1),
            maxPitch = maxPitch,
            maxRoll = maxRoll,
            internalTargetX = 0,
            internalTargetY = 0,
            goingToDestination = false,
        })
        return obj --[[@as HelicopterController]]
    end,

    ---@param self HelicopterController
    ---@param rollCommand number
    ---@param pitchCommand number
    ---@param yawCommand number
    ---@param collectiveCommand number
    ---@param goToDestination boolean
    ---@param destinationX number
    ---@param destinationY number
    ---@return table
    update = function(self, rollCommand, pitchCommand, yawCommand, collectiveCommand, goToDestination, destinationX,
                      destinationY)
        if goToDestination then
            self.goingToDestination = true
            self.internalTargetX = destinationX
            self.internalTargetY = destinationY
        end

        if not goToDestination and self.goingToDestination then
            self.goingToDestination = false
            self.internalTargetX = self.physicsSensor.x
            self.internalTargetY = self.physicsSensor.y
        end

        -- Calculate direction to destination
        local dx = self.internalTargetX - self.physicsSensor.x
        local dy = self.internalTargetY - self.physicsSensor.y
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Calculate forward and right vectors
        local heading = self.physicsSensor.heading
        local forwardX, forwardY = math.sin(heading), math.cos(heading)
        local rightX, rightY = math.cos(heading), -math.sin(heading)

        -- Calculate desired pitch and roll using dot products
        local forwardDot = (dx * forwardX + dy * forwardY) / distance
        local rightDot = (dx * rightX + dy * rightY) / distance

        pitchTarget = forwardDot * self.maxPitch
        rollTarget = rightDot * self.maxRoll


        altitudeControl, headingControl = self.autopilot:update(goToDestination and distance > 100, destinationX,
            destinationY)

        yawTarget = headingControl
        collectiveTarget = altitudeControl

        rollTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(rollTarget, rollCommand * self.maxRoll, math.abs(rollCommand))
        pitchTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(pitchTarget, pitchCommand * self.maxPitch, math.abs(pitchCommand))
        yawTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(yawTarget, yawCommand, math.abs(yawCommand))
        collectiveTarget = LifeBoatAPI.LBMaths.lbmaths_lerp(collectiveTarget, collectiveCommand,
            math.abs(collectiveCommand))

        if math.abs(collectiveCommand) > 0.01 then
            self.autopilot:setTargetAltitude(self.physicsSensor.altitude)
        end
        if (math.abs(rollCommand) > 0.01 or math.abs(pitchCommand) > 0.01) then
            self.internalTargetX = self.physicsSensor.x
            self.internalTargetY = self.physicsSensor.y
        end
        if (math.abs(yawCommand) > 0.01) then
            self.autopilot:setTargetHeading(self.physicsSensor.heading)
        end


        pitchOutput = self.pitchPID:update(self.physicsSensor.pitch, pitchTarget)
        rollOutput = self.rollPID:update(self.physicsSensor.roll, rollTarget)
        yawOutput = yawTarget
        collectiveOutput = collectiveTarget

        return {
            pitch = pitchOutput,
            roll = rollOutput,
            yaw = yawOutput,
            collective = collectiveOutput
        }
    end,

    ---@param self HelicopterController
    ---@param altitude number
    setTargetAltitude = function(self, altitude)
        self.autopilot:setTargetAltitude(altitude)
    end,
}
