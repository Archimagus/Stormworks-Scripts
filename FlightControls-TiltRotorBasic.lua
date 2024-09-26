-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey



--- Flight controls for an airplane

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

--- Control inputs
-- Input 18 (Number) A/D
-- Input 19 (Number) W/S
-- Input 20 (Number) L/R
-- Input 21 (Number) Up/Down

--- Autopilot Inputs
-- Input 21 (Number) Target Altitude
-- Input 22 (Number) Destination X
-- Input 23 (Number) Destination Y

-- Input 1 (Boolean) Reset Altitude
-- Input 2 (Boolean) Go to Destination
-- Input 3 (Boolean) Direct Mode
-- Input 4 (Boolean) Plane Mode

require('LifeBoatAPI')
require('Utils.MyIoUtils')
require('Utils.MyMath')
require('Utils.PhysicsSensor')
require('Autopilot.PlaneController')
require('Autopilot.HelicopterController')
require('Utils.ArchPid')

local physicsSensor = PhysicsSensor:new()
local autopilot = Autopilot:new(physicsSensor)
local distancePid = ArchPID:new(0.01, 0.001, 0.01, 0, 1)
local roll, pitch, yaw, collective, altitudeControl, headingControl = 0, 0, 0, 0, 0, 0
function onTick()
	rollCommand, pitchCommand, yawCommand, collectiveCommand, tgtAlt, destX, destY =
		getN(18, 19, 20, 21, 22, 23, 24)

	resetAltitude, goToDestination, directMode, planeMode = getB(1, 2, 3, 4)

	if resetAltitude or tgtAlt ~= targetAltitude then
		targetAltitude = tgtAlt
	end
	altitudeControl, headingControl = autopilot:update(goToDestination, targetAltitude, destX, destY)
	if directMode then
		outN(1, rollCommand, pitchCommand, yawCommand, collectiveCommand)
	else
		if planeMode then
			roll = headingControl
			pitch = altitudeControl
			yaw = headingControl
			collective = 1
			outN(1, roll, pitch, yaw, collective)
		else
			distanceError = distancePid:update(0, autopilot.remainingDistance)
			roll = autopilot.rightPercentToDestination * distanceError
			pitch = autopilot.forwardPercentToDestination * distanceError
			yaw = headingControl
			collective = altitudeControl
			outN(1, roll, pitch, yaw, collective)
		end
	end
end

function onDraw()
	if distancePid ~= nil then
		screen.drawText(0, 10, 'Distance: ' .. string.format('%.2f', autopilot.remainingDistance))
		screen.drawText(0, 20, 'Roll: ' .. string.format('%.2f', roll))
		screen.drawText(0, 30, 'Pitch: ' .. string.format('%.2f', pitch))
		screen.drawText(0, 40, 'Yaw: ' .. string.format('%.2f', yaw))
		screen.drawText(0, 50, 'Clctv: ' .. string.format('%.2f', collective))
		screen.drawText(0, 60, 'Dist Err: ' .. string.format('%.2f', distanceError))
	end
end
