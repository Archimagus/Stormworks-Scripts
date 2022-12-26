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
	simulator:setScreen(1, "3x3")
	simulator:setProperty("Input 1", true)
	simulator:setProperty("Input 2", false)
	simulator:setProperty("Input 3", true)
	simulator:setProperty("Input 4", true)
	simulator:setProperty("Use Buttons", true)
	simulator:setProperty("Initial Camera", 4)

	-- Runs every tick just before onTick allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)

		-- touchscreen defaults
		local screenConnection = simulator:getTouchScreen(1)
		simulator:setInputBool(1, screenConnection.isTouched)
		simulator:setInputNumber(1, screenConnection.width)
		simulator:setInputNumber(2, screenConnection.height)
		simulator:setInputNumber(3, screenConnection.touchX)
		simulator:setInputNumber(4, screenConnection.touchY)

		-- NEW! button/slider options from the UI
		simulator:setInputBool(31, simulator:getIsClicked(1)) -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
		simulator:setInputNumber(31, simulator:getSlider(1)) -- set input 31 to the value of slider 1

		simulator:setInputBool(32, simulator:getIsToggled(2)) -- make button 2 a toggle, for input.getBool(32)
		simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
	end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.MyUITools")
require("Utils.MyIoUtils")

gridX=11
gridY=7
baseStyle.bg = DarkGray
baseStyle.fg = Black
baseStyle.drawBorder=false
baseStyle.va =0
baseStyle.txo = 1
baseStyle.tyo = 0

selectedSignal = math.floor(prN("Initial Camera")) or 1
if selectedSignal == 0 then selectedSignal = 1 end
inputs = propB("Input 1", "Input 2", "Input 3", "Input 4")
useButtons = prB("Use Buttons")

validSignals={}
signalIndex=0
for k, v in ipairs(inputs) do
	if v then
		table.insert(validSignals,k)
		local index = #validSignals
		selected = k == selectedSignal
		if selected then signalIndex = index end
		if useButtons then
			addElement({ x = (index*1.1)-0.9, y = 0.5, w = 1, t = tostring(k), ri = 1, rt=selected,
				cf = function(b) if b.rt then selectedSignal = k end end
			})
		end
	end
end
if not useButtons then
	ss = addElement({ x = 0, y = 0, w = 1, st={drawBG=false, fg=Green}, t = tostring(selectedSignal) })
end


function onTick()
	tickUI()
	if not useButtons and touchedThisFrame then
		signalIndex = signalIndex+1
		if signalIndex > #validSignals then signalIndex = 1 end
		selectedSignal = validSignals[signalIndex]
		ss.t=tostring(selectedSignal)
	end
	outN(1, selectedSignal)
end

function onDraw()
	drawUI()
end
