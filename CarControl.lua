-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>

require("Utils.MyBasicUtils")
require("Utils.MyPid")
require("Utils.MyIoUtils")
require("Utils.MyMath")

cruiseControlSensitivity = property.getNumber("Cruise Control Sensitivity") or 0.25
maxCruiseSpeed = property.getNumber("Max Cruise Speed") or 100
autoReverse = property.getBool("Auto Reverse")


CP = property.getNumber("Cruise P") or 0.1
CI = property.getNumber("Cruise I") or 0.00001
CD = property.getNumber("Cruise D") or 0.001

cruisePulse = ArchPulse:new()
cruiseControl = false

cruisePID = MyUtils.PID:new(CP, CI, CD, 0, -1, 1)
targetSpeed = maxCruiseSpeed
reverse = false


accelerationRps = property.getNumber("Acceleration RPS") or 15
cruiseRps = property.getNumber("Cruise RPS") or 8
minRps = property.getNumber("Idle RPS") or 5
TP = property.getNumber("CVT P") or 0.01
TI = property.getNumber("CVT I") or 0.00001
TD = property.getNumber("CVT D") or 0.001

cvtPid = MyUtils.PID:new(TP, TI, TD, 0, 0, 1)
-- Distance between front and rear axle in blocks (inclusive)
wheelBaseBlocks = property.getNumber("Wheel Base Blocks") or 15
-- Distance between the center lines of the left and right wheels in blocks
trackWidthBlocks = property.getNumber("Track Width Blocks") or 9
wheelBase = (wheelBaseBlocks - 1) * 0.25   -- -1 because the axle is in the middle of the blocks
trackWidth = (trackWidthBlocks - 1) * 0.25 -- -1 because the center line is in the middle of the blocks


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
	end

	local throttle = throttleInput
	if cruiseControl then
		targetSpeed = clamp(targetSpeed + throttle * cruiseControlSensitivity, 0, maxCruiseSpeed)
		throttle = cruisePID:update(targetSpeed, speed)
	else
		targetSpeed = speed + throttle * 2
	end


	local braking = 0
	local throttleOut = 0
	if (abs(speed) < 1 and abs(throttle) < 0.1) then
		braking = 1
	elseif autoReverse then
		if sign(speed) ~= sign(throttleInput) then
			braking = math.abs(throttleInput)
		else
			throttleOut = math.abs(throttle)
			reverse = throttleInput < 0
		end
	else
		if throttle < 0 then
			braking = math.abs(throttleInput)
		else
			throttleOut = math.abs(throttle)
			reverse = reverseButton
		end
	end

	if eBrake or not occupied then
		cruiseControl = false
		throttleOut = 0
		braking = 1
	end


	local targetRps = minRps;
	if (braking > 0) then
		targetRps = lerp(cruiseRps, minRps, braking)
	else
		targetRps = lerp(cruiseRps, accelerationRps, throttleOut)
	end

	local clutch = 0
	if (rps > minRps) then
		clutch = clamp(rps / cruiseRps)
	end

	local cvt = 1 - cvtPid:update(targetRps, rps)
	local clutchLower = ((math.cos(cvt * (math.pi / 2))))
	local clutchUpper = ((math.sin(cvt * (math.pi / 2))))

	local clutchLower = clamp(clutchLower)
	local clutchUpper = clamp(clutchUpper)

	local leftWheelSteer, rightWheelSteer = calculateAckermannSteering(steering)

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
	-- Convert desired steering to radians (scaled by max steering angle of 0.8)
	local desiredSteeringAngle = desiredSteering * 0.8 * math.pi / 2

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
