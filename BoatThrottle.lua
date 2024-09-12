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
	local simulator = simulator

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

cruiseControlSensitivity = property.getNumber("Cruise Control Sensitivity") or 0.25 -- Cruise Control sensitivity
maxCruiseSpeed = property.getNumber("Max Cruise Speed") or 70                       -- Max cruise speed
maxReverseSpeed = property.getNumber("Max Reverse Speed") or -10                    -- Max reverse speed
P = property.getNumber("P") or 0.1
I = property.getNumber("I") or 0.00001
D = property.getNumber("D") or 0.001
cruisePID = MyUtils.PID:new(P, I, D, 0, -1, 1)
targetSpeed = 0
reverse = false
throttleDetent = false
everDetent = false

function onTick()
	local ti = input.getNumber(2)
	local speed = input.getNumber(10)

	-- if throttle input is 0 and targetSpeed is 0, reset the throttle detent
	if ti == 0 then
		throttleDetent = false
	end

	local target = clamp(targetSpeed + ti * cruiseControlSensitivity, maxReverseSpeed, maxCruiseSpeed)

	-- if target speed is about to cross 0, set it to 0
	if (ti ~= 0 and target == 0) or targetSpeed * target < 0 then
		throttleDetent = true
		everDetent = true
	end

	if throttleDetent then
		targetSpeed = 0
	else
		targetSpeed = target
	end

	local throttle = cruisePID:update(targetSpeed, speed)
	reverse = throttle < 0
	output.setNumber(1, throttle)
	output.setNumber(2, targetSpeed)
	output.setNumber(3, speed)
	output.setNumber(4, ti)

	output.setBool(1, reverse)
	output.setBool(2, throttleDetent)
	output.setBool(3, everDetent)
end
