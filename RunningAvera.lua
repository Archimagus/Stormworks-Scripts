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
    simulator:setProperty("Average Consumption Time In Seconds", 5)
	local start = 5000;
    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

		start = start - ((math.random(75, 100)-1)/60)
        simulator:setInputNumber(1, start)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("LifeBoatAPI.Maths.LBRollingAverage")

	local averageTime = property.getNumber("Average Consumption Time In Seconds")
	local samplesPerSecond = 60
	local maxTicks=averageTime*samplesPerSecond
	local average = LifeBoatAPI.LBRollingAverage:new(maxTicks);
	local level = 0
function onTick()
    local number = input.getNumber(1)
	if level == 0 then level = number end
	local diff = level-number;
	level = number;
	local avg = average:lbrollingaverage_addValue(diff)
	avg = avg*samplesPerSecond*100
	avg = math.floor(avg+0.5)/100
	output.setNumber(1, avg);
end
