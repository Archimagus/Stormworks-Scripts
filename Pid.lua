-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
-- Inputs
-- On/Off: 1
-- Numbers
-- target: 1
-- process: 2
-- p: 3
-- i: 4
-- d:5
-- minOutput: 6
-- maxOutput: 7

-- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey (Please retain this notice at the top of the file as a courtesy a lot of effort went into the creation of these tools.)
--- With LifeBoatAPI you can use the "require(...)" keyword to use code from other files!
---     This lets you share code between projects, and organise your work better.
---     The below, includes the content from SimulatorConfig.lua in the generated /_build/ folder
--- (If you want to include code from other projects, press CTRL+COMMA, and add to the LifeBoatAPI library paths)
require("Utils.MyPid")

local myPid = PID:new(
	property.getNumber("P") or 0.6,
	property.getNumber("I") or 0,
	property.getNumber("D") or 0.2,
	property.getNumber("bias") or 0,
	property.getNumber("minOutput") or -9999,
	property.getNumber("maxOutput") or 9999
)

function setPid()
	p = input.getNumber(3)
	i = input.getNumber(4)
	d = input.getNumber(5)
	minOutput = input.getNumber(6)
	maxOutput = input.getNumber(7)

	if p ~= 0 or i ~= 0 or d ~= 0 then
		myPid.p = p
		myPid.i = i
		myPid.d = d
	end
	if minOutput ~= 0 or maxOutput ~= 0 then
		myPid.minOutput = minOutput
		myPid.maxOutput = maxOutput
	end
end
function onTick()
	on = input.getBool(1)

	setPid()
	
	output.setBool(1, input.getBool(1))
	output.setNumber(6, myPid.p)
	output.setNumber(7, myPid.i)
	output.setNumber(8, myPid.d)
	if not on then
		integral_prior = 0
		output.setNumber(1, 0)
		output.setNumber(2, 0)
		output.setNumber(3, 0)
		output.setNumber(4, 0)
		return
	end

	target = input.getNumber(1)
	process = input.getNumber(2)

	value_out = myPid:update(target, process)

	output.setNumber(1, value_out)
	output.setNumber(2, myPid.error)
	output.setNumber(3, myPid.integral)
	output.setNumber(4, myPid.derivative)
end

--- Ready to put this in the game?
--- Just hit F7 and then copy the (now tiny) file from the /out/ folder

