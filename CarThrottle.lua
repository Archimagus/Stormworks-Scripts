-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
	---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
	simulator = simulator

	-- Runs every tick just before onTick; allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		simulator:setInputNumber(1, simulator:getSlider(2) * 2 - 1) -- input 1 to the value of slider 1 (between -1 and 1)
		simulator:setInputNumber(5, simulator:getSlider(5) * 10 - 5) -- input 2 to the value of slider 2 (between -5 and 5)
	end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.MyBasicUtils")
require("Utils.MyPid")

throttleType = property.getBool("Throttle Type") or 0                               -- 0 = Absolute, 1 = Signed
throttleInput = property.getNumber("Throttle Input") or 2                           -- Throttle input number (W/S = 2)
cruiseControlInput = property.getNumber("Cruse Control Input") or 2                 -- Cruise Control input number
throttleSensetivity = property.getNumber("Cruise Control Sensitivity") or 0.25 -- Cruise Control sensitivity
maxRps = property.getNumber("Max Cruise Speed") or 100                      -- Max cruise speed
speedInput = property.getNumber("Speed Input") or 5                                 -- Speed input number
eBrakeInput = property.getNumber("E-Brake Input") or 31                             -- E-Brake input number (Space = 31)

P = property.getNumber("P") or 0.1
I = property.getNumber("I") or 0.00001
D = property.getNumber("D") or 0.001

cruisePulse = ArchPulse:new()
cruiseControl = false

cruisePID = MyUtils.PID:new(P, I, D, 0, -1, 1)
targetSpeed = maxRps
reverse = false

function onTick()
	local ti = input.getNumber(throttleInput)
	local speed = input.getNumber(speedInput)
	local eBrake = input.getBool(eBrakeInput)
	local ccButton = input.getBool(cruiseControlInput)
	local cp = cruisePulse:check(ccButton)
	local occupied = input.getBool(32)
	if cp then
		cruiseControl = not cruiseControl
		targetSpeed = cruiseControl and speed or maxRps
	end

	local throttle = ti
	if cruiseControl then
		targetSpeed = clamp(targetSpeed + throttle * throttleSensetivity, 0, maxRps)
		throttle = cruisePID:update(targetSpeed, speed)
	else
		targetSpeed = speed + throttle * 2
	end


	local braking = 0
	local throttleOut = 0
	if sign(speed) ~= sign(throttle) then
		braking = math.abs(throttle)
	else
		if throttleType == 0 then
			throttleOut = math.abs(throttle)
		else
			throttleOut = throttle
		end
		reverse = throttle < 0
	end

	if eBrake or not occupied then
		cruiseControl = false
		throttleOut = 0
		braking = 1
	end

	output.setNumber(1, throttleOut)
	output.setNumber(2, braking)
	output.setNumber(3, targetSpeed)
	output.setNumber(4, speed)

	output.setBool(1, reverse)
	output.setBool(3, cruiseControl)
end

function sign(number)
	return number > 0 and 1 or (number == 0 and 0 or -1)
end
