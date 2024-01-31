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

-- Set up variables for the script
local numLights = 8
local lightStates = {}
local ticks = 0

function setRGB(light, r, g, b)
	local index = ((light - 1) * 3) + 1
	outN(index, r, g, b)
end

-- Initialize the light states to "off"
for i = 1, numLights do
	lightStates[i] = { state = "off", count = i * 8 }
end



-- Define the setLight function
function setLight(light, state)
	-- If the state of the light has changed, update the state
	if state ~= lightStates[light].state then
		-- Update the state of the light in the lightStates table
		lightStates[light].state = state

		if state == "white" then
			setRGB(light, 1, 1, 1)
		elseif state == "red" then
			setRGB(light, 1, 0, 0)
		else
			setRGB(light, 0, 0, 0)
		end
	end
end

function onTick()
	local siren1, siren2, lightsFlash, LightsFlood = getB(1, 2, 3, 4)
	outB(1, siren1, siren2)

	ticks = ticks + 1

	if lightsFlash then
		-- slow things down
		if ticks % 2 == 0 then
			-- Loop through each light
			for i = 1, numLights do
				local count = lightStates[i].count
				count = count - 1
				if count < -8 then
					count = count + 40
				end
				if count > 0 then
					if count % 3 == 0 then
						setLight(i, "white")
					else
						setLight(i, "red")
					end
				else
					setLight(i, "red")
				end
				lightStates[i].count = count
			end
		end
	elseif LightsFlood then
		for i=1,numLights do
			setLight(i, "white")
		end
	else
		for i=1,numLights do
			setLight(i, "off")
		end
	end

end
