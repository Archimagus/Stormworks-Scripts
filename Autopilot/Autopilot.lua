---@section AUTOPILOTBOILERPLATE
--- Author: Archimagus
--- An autopilot for use in various projects.
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
---@endsection

local WARMUP_FRAMES = 60

---@section Autopilot
require('Utils.ArchPid')

---@class Autopilot
---@field altitudePid ArchPID
---@field headingPid ArchPID
---@field targetAltitude number
---@field destinationX number
---@field destinationY number
---@field targetHeading number
---@field physicsSensor PhysicsSensor
---@field goToDestination boolean
---@field waitFrames number
---@field remainingDistance number
---@field eta number
---@field forwardPercentToDestination number
---@field rightPercentToDestination number
Autopilot = {
    ---@param self Autopilot
    ---@param physicsSensor PhysicsSensor
    ---@return Autopilot
    new = function(self, physicsSensor)
        local obj = LifeBoatAPI.lb_copy(self, {
            altitudePid = ArchPID:new(0.05, 0.001, 0.05, -1, 1),
            headingPid = ArchPID:new(1, 0.1, 0.01, -1, 1),
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
    update = function(self, goToDestination, targetAltitude, destinationX, destinationY)
        self.physicsSensor:read()
        local currentAltitude = self.physicsSensor.altitude
        local currentHeading = self.physicsSensor.heading

        self.targetAltitude = targetAltitude
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

        -- Calculate direction to destination
        local dx = self.destinationX - self.physicsSensor.x
        local dy = self.destinationY - self.physicsSensor.y
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Calculate forward and right vectors
        local heading = self.physicsSensor.heading
        local forwardX, forwardY = math.sin(heading), math.cos(heading)
        local rightX, rightY = math.cos(heading), -math.sin(heading)

        if goToDestination then
            self.targetHeading = math.atan(dx, dy)
        elseif self.goToDestination then
            self.targetHeading = currentHeading
        end
        self.goToDestination = goToDestination

        if self.destinationX ~= 0 or self.destinationY ~= 0 or self.goToDestination then
            self.remainingDistance = distance
            self.eta = distance / self.physicsSensor.forwardVelocity
            self.forwardPercentToDestination = dx * forwardX + dy * forwardY
            self.rightPercentToDestination = dx * rightX + dy * rightY
        else
            self.remainingDistance = 0
            self.eta = 0
            self.forwardPercentToDestination = 0
            self.rightPercentToDestination = 0
        end
        local headingError = LifeBoatAPI.LBMaths.lbmaths_angularSubtract(self.targetHeading, currentHeading)

        local altitudeControl = self.altitudePid:update(self.targetAltitude, currentAltitude)
        local headingControl = -self.headingPid:update(0, headingError)

        return altitudeControl, headingControl
    end,
}
---@endsection
