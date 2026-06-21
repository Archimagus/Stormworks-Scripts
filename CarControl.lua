-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

require("Utils.MyBasicUtils")
require("Utils.MyPid")
require("Utils.MyIoUtils")
require("Utils.MyMath")

throttleSensetivity = propertyOrDefault("Cruise Control Sensitivity", 0.25)
maxRps = propertyOrDefault("Max Cruise Speed", 100)
autoReverse = property.getBool("Auto Reverse")
stopSpeed = 1
throttleDeadband = 0.1


CP = propertyOrDefault("Cruise P", 0.1)
CI = propertyOrDefault("Cruise I", 0.00001)
CD = propertyOrDefault("Cruise D", 0.001)

cruisePulse = ArchPulse:new()
cruiseControl = false

cruisePID = MyUtils.PID:new(CP, CI, CD, 0, -1, 1)
targetSpeed = maxRps
reverse = false


accelerationRps = propertyOrDefault("Acceleration RPS", 15)
cruiseRps = propertyOrDefault("Cruise RPS", 8)
minRps = propertyOrDefault("Idle RPS", 5)
TP = propertyOrDefault("CVT P", 0.01)
TI = propertyOrDefault("CVT I", 0.00001)
TD = propertyOrDefault("CVT D", 0.001)

cvtPid = MyUtils.PID:new(TP, TI, TD, 0, 0, 1)
-- Distance between front and rear axle in blocks (inclusive)
wheelBaseBlocks = propertyOrDefault("Wheel Base Blocks", 15)
-- Distance between the center lines of the left and right wheels in blocks
trackWidthBlocks = propertyOrDefault("Track Width Blocks", 9)
wheelBase = (wheelBaseBlocks - 1) * 0.25   -- -1 because the axle is in the middle of the blocks
trackWidth = (trackWidthBlocks - 1) * 0.25 -- -1 because the center line is in the middle of the blocks

steeringReductionSpeed = propertyOrDefault("Steering Reduction Speed", 75)
minSteeringAtSpeed = propertyOrDefault("Min Steering At Speed", 0.35)
ackermannInnerRadiusMargin = 0.1
-- Easing function to apply to the steering input
easeType = property.getText("Steering Ease Type") or "Cubic"
-- Some vehicles have the wheels on diferently.
 invertSteering = property.getBool("Invert Steering") or false

function onTick()
	local steering = input.getNumber(1)
	local throttleInput = input.getNumber(2)
	local rps = input.getNumber(3)
	local speed = input.getNumber(4)

	local reverseButton = input.getBool(2)
	local ccButton = input.getBool(3)
	local eBrake = input.getBool(31)
	local occupied = input.getBool(32)

	local inputCruiseP = input.getNumber(5)
	if inputCruiseP ~= 0 then
		CP = inputCruiseP
		CI = input.getNumber(6)
		CD = input.getNumber(7)

		if cruisePID.i ~= CI then
			cruisePID:reset()
		end

		cruisePID.p = CP
		cruisePID.i = CI
		cruisePID.d = CD
	end
	local inputCVTP = input.getNumber(8)
	if inputCVTP ~= 0 then
		TP = inputCVTP
		TI = input.getNumber(9)
		TD = input.getNumber(10)

		if cvtPid.i ~= TI then
			cvtPid:reset()
		end

		cvtPid.p = TP
		cvtPid.i = TI
		cvtPid.d = TD
	end

	local cp = cruisePulse:check(ccButton)
	if cp then
		cruiseControl = not cruiseControl
		targetSpeed = cruiseControl and speed or 0
		cruisePID:reset()
	end

	local throttle = throttleInput
	if cruiseControl then
		targetSpeed = clamp(targetSpeed + throttle * throttleSensetivity, 0, maxRps)
		throttle = cruisePID:update(targetSpeed, speed)
	else
		targetSpeed = speed + throttle * 2
	end


	local braking = 0
	local throttleOut = 0
	if math.abs(speed) < stopSpeed then
		if math.abs(throttle) < throttleDeadband then
			braking = 1
		else
			throttleOut = math.abs(throttle)
			reverse = throttleInput < 0
		end
	elseif autoReverse then
		if math.abs(throttleInput) > throttleDeadband and sign(speed) ~= sign(throttleInput) then
			braking = clamp(math.abs(throttleInput))
		else
			throttleOut = math.abs(throttle)
			reverse = throttleInput < 0
		end
	else
		if throttle < 0 then
			braking = clamp(math.abs(throttleInput))
		else
			throttleOut = math.abs(throttle)
			reverse = reverseButton
		end
	end

	if eBrake or not occupied then
		if cruiseControl then
			cruisePID:reset()
		end
		cruiseControl = false
		throttleOut = 0
		braking = 1
	end

	targetRps = minRps;
	if (braking > 0) then
		targetRps = lerp(cruiseRps, minRps, braking)
	else
		targetRps = lerp(cruiseRps, accelerationRps, throttleOut)
	end

	clutch = 0
	if (rps > minRps) then
		clutch = clamp(rps / cruiseRps)
	end

	cvt = 1 - cvtPid:update(targetRps, rps)
	clutchLower = ((math.cos(cvt * (math.pi / 2))))
	clutchUpper = ((math.sin(cvt * (math.pi / 2))))

	clutchLower = clamp(clutchLower)
	clutchUpper = clamp(clutchUpper)

	steeringScale = lerp(1, minSteeringAtSpeed, clamp(math.abs(speed) / steeringReductionSpeed))
	leftWheelSteer, rightWheelSteer = calculateAckermannSteering(steering * steeringScale)
	if invertSteering then
		leftWheelSteer = -leftWheelSteer
		rightWheelSteer = -rightWheelSteer
	end

	outN(1
	, throttleOut  -- 1
	, braking      -- 2
	, clutch       -- 3
	, clutchLower  -- 4
	, clutchUpper  -- 5
	, leftWheelSteer -- 6
	, rightWheelSteer -- 7
	, cvt          -- 8
	, rps          -- 9
	, targetRps    -- 10
	, speed        -- 11
	, targetSpeed  -- 12
	, CP           -- 13
	, CI           -- 14
	, CD           -- 15
	, TP           -- 16
	, TI           -- 17
	, TD           -- 18
	)


	output.setBool(1, reverse)
	output.setBool(2, cruiseControl)
end

function calculateAckermannSteering(desiredSteering)
	-- Apply easing function based on the easeType property
	local easedSteering = clamp(applyEasing(clamp(desiredSteering, -1, 1), easeType), -1, 1)

	local geometryLimit = math.atan(wheelBase / (trackWidth / 2 + ackermannInnerRadiusMargin)) / (math.pi / 2)
	local steeringLimit = math.min(0.8, geometryLimit)

	-- Convert desired steering to radians while keeping Ackermann geometry stable.
	local desiredSteeringAngle = easedSteering * steeringLimit * math.pi / 2

	if math.abs(desiredSteeringAngle) < 0.0001 then
		return 0, 0
	end

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
---@param localEaseType string
---@return number
function applyEasing(input, localEaseType)
	if localEaseType == "Linear" then
		return input
	elseif localEaseType == "Quadratic" then
		return input * math.abs(input)
	elseif localEaseType == "Cubic" then
		return input * input * input
	elseif localEaseType == "Sine" then
		return sign(input) * (1 - math.cos((input * math.pi) / 2))
	elseif localEaseType == "Circular" then
		return sign(input) * (1 - math.sqrt(1 - input * input))
	else
		-- Default to Linear if an invalid easeType is provided
		return input
	end
end

