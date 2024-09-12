--- CVT Controller
-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("Utils.MyPid")
require("Utils.MyMath")

P = property.getNumber("P") or 0.01
I = property.getNumber("I") or 0.00001
D = property.getNumber("D") or 0.001
accelerationRps = property.getNumber("Acceleration RPS") or 15
cruiseRps = property.getNumber("Cruise RPS") or 8
minRps = property.getNumber("Idle RPS") or 5
accelScale = property.getNumber("Acceleration Scale") or 0.5

cvtPid = MyUtils.PID:new(P, I, D, 0, 0, 1)
function onTick()
	local throttle = input.getNumber(1)
	local braking = input.getNumber(2)
	local rps = input.getNumber(5)
	local targetSpeed = input.getNumber(3)
	local speed = input.getNumber(4)

	local accel = clamp((targetSpeed - speed) * accelScale, -1, 1)
	local targetRps = minRps;
	if (accel < 0) then
		targetRps = lerp(cruiseRps, minRps, -accel)
	else
		targetRps = lerp(cruiseRps, accelerationRps, accel)
	end

	local clutch = 0
	if (rps > minRps) then
		clutch = 1
	end

	local cvt = cvtPid:update(rps, targetRps)
	local clutchLower = ((math.cos(cvt * (math.pi / 2))))
	local clutchUpper = ((math.sin(cvt * (math.pi / 2))))

	local clutchLower = clamp(clutchLower, 0, 1) * clutch
	local clutchUpper = clamp(clutchUpper, 0, 1) * clutch


	output.setNumber(1, throttle)
	output.setNumber(2, braking)
	output.setNumber(3, targetSpeed)
	output.setNumber(4, speed)

	local reverse = input.getBool(1)
	local cruiseControl = input.getBool(3)
	output.setBool(1, reverse)
	output.setBool(3, cruiseControl)

	output.setNumber(5, cvt)
	output.setNumber(6, clutchLower)
	output.setNumber(7, clutchUpper)
	output.setNumber(8, rps)
	output.setNumber(9, targetRps)
end
