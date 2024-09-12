-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561197993236437/myworkshopfiles/?appid=573090
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

	-- Runs every tick just before onTick; allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		simulator:setInputBool(1, simulator:getIsToggled(1))
		simulator:setInputBool(2, simulator:getIsToggled(2))
		simulator:setInputBool(3, simulator:getIsToggled(3))
		simulator:setInputBool(4, simulator:getIsToggled(4))
	end

	;
end
---@endsection


--[====[ IN-GAME CODE ]====]
-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.MyIoUtils")




function onTick()
	local headlights, brakes, reverse = getB(1, 2, 4)
	if brakes then
		outN(1, 0.75, 0, 0)
	elseif reverse then
		outN(1, 0.5, 0.5, 0.5)
	elseif headlights then
		outN(1, 0.25, 0, 0)
	else
		outN(1, 0, 0, 0)
	end
end
