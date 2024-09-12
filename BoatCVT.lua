--- CVT Controller
-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("Utils.MyPid")
require("Utils.MyMath")
require("Utils.MyIoUtils")

P = property.getNumber("P") or 0.01
I = property.getNumber("I") or 0.00001
D = property.getNumber("D") or 0.001
maxSpeed = property.getNumber("Max Speed") or 100
accelerationRps = property.getNumber("Acceleration RPS") or 15
cruiseRps = property.getNumber("Cruise RPS") or 8
minRps = property.getNumber("Idle RPS") or 5
accelScale = property.getNumber("Acceleration Scale") or 0.5

cvtPid = MyUtils.PID:new(P, I, D, 0, 0, 1)
function onTick()
	local throttle = input.getNumber(1)
	local rps = input.getNumber(2)
	local speed = input.getNumber(3)

	local inputP = input.getNumber(4)
	if inputP ~= 0 then
		inputI = input.getNumber(5)
		inputD = input.getNumber(6)

		if cvtPid.i ~= inputI then
			cvtPid:reset()
		end

		cvtPid.p = inputP
		cvtPid.i = inputI
		cvtPid.d = inputD
	end

	local targetSpeed = throttle * maxSpeed
	local accel = clamp((targetSpeed - speed) * accelScale, -1, 1)
	local targetRps = minRps;
	if (accel < 0) then
		targetRps = lerp(cruiseRps, minRps, -accel)
	else
		targetRps = lerp(cruiseRps, accelerationRps, accel)
	end

	local clutch = 0
	if (rps > minRps) then
		clutch = clamp(rps / cruiseRps)
	end

	local cvt = 1 - cvtPid:update(targetRps, rps)
	local clutchLower = ((math.cos(cvt * (math.pi / 2))))
	local clutchUpper = ((math.sin(cvt * (math.pi / 2))))

	local clutchLower = clamp(clutchLower, 0, 1) * clutch
	local clutchUpper = clamp(clutchUpper, 0, 1) * clutch

	outN(1
	, throttle       -- 1
	, clutch         -- 2
	, clutchLower    -- 3
	, clutchUpper    -- 4
	, cvt            -- 5
	, rps            -- 6
	, targetRps      -- 7
	, speed          -- 8
	, targetSpeed    -- 9
	, cvtPid.p       -- 10
	, cvtPid.i       -- 11
	, cvtPid.d       -- 12
	, cvtPid.lastError -- 13
	, cvtPid.integral -- 14
	, cvtPid.derivative -- 15
	)

	local reverse = input.getBool(1)
	output.setBool(1, reverse)
end
