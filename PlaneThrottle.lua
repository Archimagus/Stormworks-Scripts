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

throttleSensetivity = property.getNumber("Throttle Sensitivity") or 0.25
minRps = property.getNumber("Idle RPS") or 10   
lowRps = property.getNumber("Plane Low RPS") or 50         
maxRps = property.getNumber("Plane Max RPS") or 100               
targetRps = 0

function clamp(number, min, max)
	min = min or 0
	max = max or 1
	return math.min(math.max(number, min), max)
end
function onTick()
	local throttleUp = input.getBool(1)
	local throttleDown = input.getBool(2)
	local resetToLowRps = input.getBool(3)
	local enabled = input.getBool(4)

	if enabled then
		if resetToLowRps then
			targetRps = lowRps
		end	
		if throttleUp then
			targetRps = targetRps + throttleSensetivity
		end
		if throttleDown then
			targetRps = targetRps - throttleSensetivity
		end
		targetRps = clamp(targetRps, minRps, maxRps)
	end

	output.setNumber(1, targetRps)
end