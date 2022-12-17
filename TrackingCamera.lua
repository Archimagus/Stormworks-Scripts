require("MyMath")
require("MyUITools")

minp = property.getNumber("Min Camera Pan Speed") or 0.1
maxp = property.getNumber("Max Camera Pan Speed") or 0.1
mint = property.getNumber("Min Camera Tilt Speed") or 0.1
maxt = property.getNumber("Max Camera Tilt Speed") or 0.1
zoomSpeed = property.getNumber("Zoom Speed") or 0.01

invertT = property.getBool("Invert Tilt")
invertP = property.getBool("Invert Pan")
laserEnable=false
lightEnable=false

local lz = addElement({x=0, y=0, w=1, t="LZ", tg=false,
	uf=function(b) outB(1,b.tg) end -- Output true on channel if button is toggled
})
local sp = addElement({x=0, y=1, w=1, t="SP", tg=false,
	uf=function(b) outB(2,b.tg) end -- Output true on channel if button is toggled
})
local ir = addElement({x=0, y=2, w=1, t="IR", tg=false,
	uf=function(b) outB(3,b.tg) end -- Output true on channel if button is toggled
})
zoom=0
pitch=0
baseStyle.bg=Black
baseStyle.fg=Green

addElement({x=7, y=0, t="+", hf=function(b) zoom = clamp(zoom + zoomSpeed, 0, 1) end})
addElement({x=7, y=7, t="-", hf=function(b) zoom = clamp(zoom - zoomSpeed, 0, 1) end})

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
	p = input.getNumber(1)
	tilt = input.getNumber(2)
	z = input.getNumber(4)
	zoom = clamp(zoom + zoomSpeed*z, 0, 1)

	fov = 1-((1-zoom)^3) -- ease the value to make zoom slower it gets tighter
	output.setNumber(1, p*-lerp(maxp, minp,fov) * invertPan)
	pitch = clamp(pitch + (tilt*lerp(maxt, mint,fov) * invertTilt), -1,1)
	output.setNumber(2, pitch)
	output.setNumber(4, fov)

end

function onDraw()
	drawUI()
	screen.setColor(0, 255, 0)
	screen.drawText(2, screen.getHeight() - 6, "" .. math.floor(distance) .. "m")
end	