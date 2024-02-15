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

	-- Runs every tick just before onTick allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		-- touchscreen defaults
		local screenConnection = simulator:getTouchScreen(1)
		simulator:setInputBool(1, screenConnection.isTouched)
		simulator:setInputBool(2, screenConnection.isTouchedAlt)
		simulator:setInputNumber(1, screenConnection.width)
		simulator:setInputNumber(2, screenConnection.height)
		simulator:setInputNumber(3, screenConnection.touchX)
		simulator:setInputNumber(4, screenConnection.touchY)

		-- NEW! button/slider options from the UI
		simulator:setInputBool(5, simulator:getIsClicked(1))
		simulator:setInputBool(6, simulator:getIsClicked(2))
		simulator:setInputBool(7, simulator:getIsClicked(3))
		simulator:setInputBool(8, simulator:getIsClicked(4))

		simulator:setInputNumber(32, simulator:getSlider(1) * 20)
	end
end
---@endsection

--[====[ IN-GAME CODE ]====]
require("Utils.MyMath")
require("Utils.MyUITools")

minp = property.getNumber("Min Camera Pan Speed") or 0.1
maxp = property.getNumber("Max Camera Pan Speed") or 0.1
mint = property.getNumber("Min Camera Tilt Speed") or 0.1
maxt = property.getNumber("Max Camera Tilt Speed") or 0.1
zoomSpeed = property.getNumber("Zoom Speed") or 0.01

invertT = property.getBool("Invert Tilt")
invertP = property.getBool("Invert Pan")
laserEnable = false
lightEnable = false

local zoom = 0
local tilt = 0
local pan = 0

gridX = 11
gridY = 7
baseStyle.bg = Arch_DarkGray
baseStyle.fg = Arch_Black
baseStyle.drawBorder = false
baseStyle.va = 0
baseStyle.txo = 1
baseStyle.tyo = 0

local lz = addElement({
	x = 7.5,
	y = 3,
	w = 1,
	t = "LZ",
	tg = false,
	uf = function(b) outB(1, b.tg) end -- Output true on channel if button is toggled
})
local st = addElement({
	x = 7.5,
	y = 5,
	w = 1,
	t = "ST",
	tg = false,
	uf = function(b) outB(2, b.tg) end -- Output true on channel if button is toggled
})
local tr = addElement({
	x = 7.5,
	y = 7,
	w = 1,
	t = "TR",
	tg = false,
	uf = function(b) outB(3, b.tg) end -- Output true on channel if button is toggled
})
local ir = addElement({
	x = 7.5,
	y = 9,
	w = 1,
	t = "IR",
	tg = false,
	uf = function(b) outB(4, b.tg) end -- Output true on channel if button is toggled
})

local zi = addElement({ x = 7.5, y = 0.1, t = "+", st = { ha = 0, va = 0, txo = 1, tyo = 0 }, hf = function(b) zoom =
	clamp(zoom + zoomSpeed, 0, 1) end })
local zo = addElement({ x = 7.5, y = 12.6, t = "-", st = { ha = 0, va = 0, txo = 1, tyo = 0 }, hf = function(b) zoom =
	clamp(zoom - zoomSpeed, 0, 1) end })

function press(b, press)
	if press then
		if not b.tcp then
			b.tcp = true
			toggleB(b)
		end
	else
		b.tcp = false
	end
end

function onTick()
	tickUI()

	invertTilt = 1
	if invertT then
		invertTilt = -1
	end
	invertPan = 1
	if invertP then
		invertPan = -1
	end
	distance = input.getNumber(10)
	local p = input.getNumber(5)
	local t = input.getNumber(6)
	local z = input.getNumber(7)

	if z > 0.1 then zi.p = true end
	if z < -0.1 then zo.p = true end

	press(lz, input.getBool(5))
	press(st, input.getBool(6))
	press(tr, input.getBool(7))
	press(ir, input.getBool(8))

	zoom = clamp(zoom + zoomSpeed * z, 0, 1)
	fov = 1 - (1 - zoom) * (1 - zoom); -- ease the value to make zoom slower it gets tighter
	tilt = t * lerp(maxt, mint, fov) * invertTilt
	pan = p * -lerp(maxp, minp, fov) * invertPan

	output.setNumber(1, pan)
	output.setNumber(2, tilt)
	output.setNumber(4, fov)
end

function onDraw()
	drawUI()
	screen.setColor(0, 255, 0)
	screen.drawText(2, screen.getHeight() - 6, "" .. math.floor(distance) .. "m")
end
