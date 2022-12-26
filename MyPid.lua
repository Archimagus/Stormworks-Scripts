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
require("Utils.MyMath")
local error_prior = 0
local integral_prior = 0
local derivative = 0
local kp = 0
local ki = 0
local kd = 0
local bias = 0
function getSign(error)
	if error < 0 then
		return -1
	else
		return 1
	end
end

function setPid()
	p = input.getNumber(3)
	i = input.getNumber(4)
	d = input.getNumber(5)
	minOutput = input.getNumber(6)
	maxOutput = input.getNumber(7)

	if minOutput == 0 and maxOutput == 0 then
		minOutput = property.getNumber("minOutput") or -9999
		maxOutput = property.getNumber("maxOutput") or 9999
	end
	if p == 0 and i == 0 and d == 0 then
		p = property.getNumber("P") or 0.6
		i = property.getNumber("I") or 0
		d = property.getNumber("D") or 0.2
	end
	if p ~= 0 or i ~= 0 or d ~= 0 then
		kp = p
		ki = i
		kd = d
	end
end
function onTick()
	on = input.getBool(1)
	if not on then

		integral_prior = 0
		output.setNumber(1, 0)
		output.setNumber(2, 0)
		output.setNumber(3, 0)
		output.setNumber(4, 0)

		output.setNumber(6, kp)
		output.setNumber(7, ki)
		output.setNumber(8, kd)
		return
	end

	target = input.getNumber(1)
	process = input.getNumber(2)
	setPid()

	error = target - process
	integral = integral_prior + error
	derivative = error - error_prior

	value_out = kp * error + ki * integral + kd * derivative + bias

	if value_out > maxOutput or value_out < minOutput then
		integral = integral - error
	end


	error_prior = error
	integral_prior = integral

	clamp(value_out, minOutput, maxOutput)

	output.setNumber(1, value_out)
	output.setNumber(2, error)
	output.setNumber(3, integral)
	output.setNumber(4, derivative)

	output.setNumber(6, kp)
	output.setNumber(7, ki)
	output.setNumber(8, kd)

	output.setBool(1, input.getBool(1))
end

--- Ready to put this in the game?
--- Just hit F7 and then copy the (now tiny) file from the /out/ folder

