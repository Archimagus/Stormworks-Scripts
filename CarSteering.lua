-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

-- Distance between front and rear axle in blocks (inclusive)
local wheelBaseBlocks = property.getNumber("Wheel Base Blocks") or 15
-- Distance between the center lines of the left and right wheels in blocks
local trackWidthBlocks = property.getNumber("Track Width Blocks") or 9
local wheelBase = (wheelBaseBlocks - 1) * 0.25   -- -1 because the axle is in the middle of the blocks
local trackWidth = (trackWidthBlocks - 1) * 0.25 -- -1 because the center line is in the middle of the blocks

local easeType = property.getText("Ease Type") or "Linear"

-- Some vehicles have the wheels on diferently.
local invertSteering = property.getBool("Invert Steering") or false

function onTick()
	local steering = input.getNumber(1)
	local leftWheelSteer, rightWheelSteer = calculateAckermannSteering(steering)

	if invertSteering then
		leftWheelSteer = -leftWheelSteer
		rightWheelSteer = -rightWheelSteer
	end

	output.setNumber(1, leftWheelSteer)
	output.setNumber(2, rightWheelSteer)
end

-- Calculate Ackermann steering based on the desired steering input
---@param desiredSteering number
---@return number leftWheelSteer
---@return number rightWheelSteer
function calculateAckermannSteering(desiredSteering)
	-- Apply easing function based on the easeType property
	local easedSteering = applyEasing(desiredSteering)

	-- Convert eased steering to radians (scaled by max steering angle of 0.8)
	local desiredSteeringAngle = easedSteering * math.pi / 2

	-- Calculate turning radius
	local turningRadius = wheelBase / math.tan(desiredSteeringAngle)

	-- Calculate steering angles for left and right wheels
	local leftWheelSteer = math.atan(wheelBase / (turningRadius + trackWidth / 2))
	local rightWheelSteer = math.atan(wheelBase / (turningRadius - trackWidth / 2))

	-- Normalize steering angles to range from -1 to 1
	leftWheelSteer = leftWheelSteer / (math.pi / 2)
	rightWheelSteer = rightWheelSteer / (math.pi / 2)

	-- invert the left wheel steer because of mirroring oddness
	return -leftWheelSteer, rightWheelSteer
end

-- Apply easing function based on the easeType property
---@param input number
---@return number
function applyEasing(input)
	if easeType == "Linear" then
		return input
	elseif easeType == "Quadratic" then
		return input * math.abs(input)
	elseif easeType == "Cubic" then
		return input * input * input
	elseif easeType == "Sine" then
		return 1 - math.cos(input * math.pi / 2)
	elseif easeType == "Circular" then
		return 1 - math.sqrt(1 - input * input)
	else
		-- Default to Linear if an invalid easeType is provided
		return input
	end
end
