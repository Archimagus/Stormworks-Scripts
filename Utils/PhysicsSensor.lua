---@section PHYSICSENSORBOILERPLATE
--- Author: Archimagus
--- Utilities for reading physics sensor data.
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
---@endsection

--- Physics sensor inputs
-- Input 1 to 3 (Number): X, Y and Z position of the block
-- Input 4 to 6 (Number): Euler rotation X, Y and Z of the block
-- Input 7 to 9 (Number): Linear velocity X, Y and Z of the block
-- Input 10 to 12 (Number): Angular velocity X, Y and Z of the block
-- Input 13 (Number): Absolute linear velocity of the block
-- Input 14 (Number): Absolute angular velocity of the block
-- Input 15 (Number): Local Z tilt (pitch)
-- Input 16 (Number): Local X tilt (roll)
-- Input 17 (Number): Compass heading (-0.5 to 0.5)

---@section PhysicsSensor

require('Utils.MyIoUtils')
require('LifeBoatAPI')

---@diagnostic disable: duplicate-doc-field
---@class PhysicsSensor
---@field x number -- World X position
---@field y number -- World Y position
---@field altitude number -- World altitude
---@field pitch number -- Local pitch
---@field roll number -- Local roll
---@field heading number -- Local heading
---@field forwardVelocity number -- Local forward velocity
---@field rightVelocity number -- Local right velocity
---@field upVelocity number -- Local vertical velocity
---@field verticalVelocity number -- Global vertical velocity
---@field rollVelocity number -- Local roll velocity
---@field pitchVelocity number -- Local pitch velocity
---@field yawVelocity number -- Local yaw velocity
---@field rawHeading number -- Raw heading
---@field read function -- Call during update to read the sensor
PhysicsSensor = {
    ---@param self PhysicsSensor
    ---@return PhysicsSensor
    new = function(self)
        local obj = LifeBoatAPI.lb_copy(self, {
            x = 0,
            y = 0,
            altitude = 0,
            pitch = 0,
            roll = 0,
            heading = 0,
            forwardVelocity = 0,
            rightVelocity = 0,
            upVelocity = 0,
            verticalVelocity = 0,
            rollVelocity = 0,
            pitchVelocity = 0,
            yawVelocity = 0,
            rawHeading = 0,
        })
        return obj --[[@as PhysicsSensor]]
    end,

    ---@param self PhysicsSensor
    read = function(self)
        X, Y, Z, RX, RY, RZ, VX, VY, VZ, RVX, RVY, RVZ, ALV, AAV, PITCH, ROLL, HEADING = getN(1, 2, 3, 4, 5, 6, 7, 8, 9,
            10, 11, 12, 13, 14, 15, 16, 17)

        -- Calculate vertical velocity by integrating altitude
        self.verticalVelocity = (Y - self.altitude) * 60
        self.x = X
        self.y = Z
        self.altitude = Y
        self.pitch = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(PITCH)
        self.roll = -LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(ROLL)
        self.heading = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth(HEADING)
        self.rawHeading = HEADING
        self.forwardVelocity = VZ
        self.rightVelocity = VX
        self.upVelocity = VY
        self.rollVelocity = RVZ
        self.pitchVelocity = RVX
        self.yawVelocity = RVY
    end
}
---@endsection
