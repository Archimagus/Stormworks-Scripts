-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("Utils.MyPid")

P = property.getNumber("P") or 0.01
I = property.getNumber("I") or 0.00001
D = property.getNumber("D") or 0.001
targetRps = property.getNumber("Target RPS")
minRps = property.getNumber("Idle RPS")

cvtPid = MyUtils.PID:new(P, I, D, 0, 0, 1)
clutch = 0
function onTick()
	rps = input.getNumber(1)
	local inputNumber = input.getNumber(2)
	if inputNumber ~= 0 then
		targetRps = inputNumber
	end
	if (rps > minRps) then
		clutch = 1
	else
		clutch = 0
	end
	cvt = cvtPid:update(rps, targetRps)
	clutchLower = ((math.cos(cvt * (math.pi / 2))))
	clutchUpper = ((math.sin(cvt * (math.pi / 2))))

	clutchLower = clamp(clutchLower, 0, 1) * clutch
	clutchUpper = clamp(clutchUpper, 0, 1) * clutch

	output.setNumber(1, cvt)
	output.setNumber(2, clutchLower)
	output.setNumber(3, clutchUpper)
end
