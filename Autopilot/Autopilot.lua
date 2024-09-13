ArchUtils = ArchUtils or {}

local WARMUP_FRAMES = 60

---@class Autopilot
---@field altitudePid ArchPID
---@field headingPid ArchPID
---@field targetAltitude number
---@field targetHeading number
---@field destinationX number
---@field destinationY number
---@field physicsSensor PhysicsSensor
---@field goToDestination boolean
---@field waitFrames number
---@field eta number
---@field remainingDistance number
ArchUtils.Autopilot = {
    ---@param cls Autopilot
    ---@param physicsSensor PhysicsSensor
    ---@return Autopilot
    new = function(cls, physicsSensor)
        local obj = LifeBoatAPI.lb_copy(cls, {
            altitudePid = ArchUtils.ArchPID:new(0.05, 0.001, 0.05, -1, 1),
            headingPid = ArchUtils.ArchPID:new(1, 0.1, 0.01, -1, 1),
            targetAltitude = 0,
            destinationX = 0,
            destinationY = 0,
            targetHeading = math.maxinteger,
            physicsSensor = physicsSensor,
            goToDestination = false,
            waitFrames = 0,
            eta = 0,
            remainingDistance = 0,
        })
        return obj --[[@as Autopilot]]
    end,

    ---@param self Autopilot
    ---@param goToDestination boolean
    ---@return number, number
    update = function(self, goToDestination, destinationX, destinationY)
        self.physicsSensor:read()
        local currentAltitude = self.physicsSensor.altitude
        local currentHeading = self.physicsSensor.heading

        self.destinationX = destinationX
        self.destinationY = destinationY

        -- Physics sensor takea a few frames to get valid data
        if self.targetHeading == math.maxinteger and self.waitFrames < WARMUP_FRAMES then
            self.waitFrames = self.waitFrames + 1
            if self.waitFrames == WARMUP_FRAMES then
                self.targetHeading = currentHeading
                self.targetAltitude = currentAltitude
            end
        end

        local altitudeError = self.targetAltitude - currentAltitude

        if goToDestination then
            -- Calculate the target heading based on current position and destination
            local dx = self.destinationX - self.physicsSensor.x
            local dy = self.destinationY - self.physicsSensor.y
            self.targetHeading = math.atan(dx, dy)
            self.remainingDistance = math.sqrt(dx * dx + dy * dy)
            self.eta = self.remainingDistance / self.physicsSensor.forwardVelocity
        elseif self.goToDestination then
            self.targetHeading = currentHeading
        end
        self.goToDestination = goToDestination

        local headingError = LifeBoatAPI.LBMaths.lbmaths_angularSubtract(self.targetHeading, currentHeading)

        local altitudeControl = -self.altitudePid:update(altitudeError, 0)
        local headingControl = -self.headingPid:update(headingError, 0)

        return altitudeControl, headingControl
    end,

    ---@param self Autopilot
    ---@param altitude number
    setTargetAltitude = function(self, altitude)
        self.targetAltitude = altitude
    end,

    ---@param self Autopilot
    ---@param heading number
    setTargetHeading = function(self, heading)
        self.targetHeading = heading
    end
}
