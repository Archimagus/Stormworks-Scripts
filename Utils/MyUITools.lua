---@section MyUITools
require("Utils.MyIoUtils")

w = 0
h = 0
gridX = 12
gridY = 12
gridXSpace = 0
gridYSpace = 0

dTB = screen.drawTextBox
dR = screen.drawRect
dRF = screen.drawRectF
sC = screen.setColor

function inRect(x, y, a, b, w, h) return x > a and y > b and x < a + w and y < b + h end

function Black() sC(0, 0, 0) end

function White() sC(255, 255, 255) end

function Red() sC(255, 0, 0) end

function Lime() sC(0, 255, 0) end

function Blue() sC(0, 0, 255) end

function Yellow() sC(255, 255, 0) end

function Cyan() sC(0, 255, 255) end

function Magenta() sC(255, 0, 255) end

function Silver() sC(192, 192, 192) end

function Gray() sC(128, 128, 128) end

function DarkGray() sC(32, 32, 32) end

function Maroon() sC(128, 0, 0) end

function Olive() sC(128, 128, 0) end

function Green() sC(0, 128, 0) end

function Purple() sC(128, 0, 128) end

function Teal() sC(0, 128, 128) end

function Navy() sC(0, 0, 128) end

function Brown() sC(165, 42, 42) end

backgroundColor = nil -- screen backgroundColor

baseStyle = {
	bg = Gray, -- background color
	fg = Brown, -- foreground color
	p = Red, -- pressed color
	tg = Blue, -- toggled color
	bdr = Maroon, -- border color
	drawBorder = true, -- draw the border?
	drawBG = true, -- draw the border?
	ha = 0, -- horizontal text alignment
	va = 0, -- vertical text alignment
	txo = 0, -- text X offset
	tyo = 0, -- text Y offset
}

function getRect(b, f)
	local r = { b.x * (gridX + gridXSpace), b.y * (gridY + gridYSpace), b.w * gridX, b.h * gridY }
	if f then
		r[3] = r[3] * (b.fillHeight or 1)
		r[4] = r[4] * (b.fillWidth or 1)
	end
	return r
end

function addElement(e)
	e.x = e.x or 0
	e.y = e.y or 0
	e.w = e.w or 1
	e.h = e.h or 1
	e.t = e.t or ""
	-- style override
	--e.tg  make button toggle
	--e.ri  radio button index
	--e.rt  radio toggled initial state
	--e.cf  click funtion
	--e.hf  hold funtion
	--e.uf  update function
	if e.tg ~= nil or e.cf ~= nil or e.hf ~= nil or e.ri ~= nil then
		e.p = false -- make this a clickable element if any of the above are defined
	end

	if e.st == nil then
		e.st = baseStyle
		else
		for k, v in pairs(baseStyle) do
			if e.st[k] == nil then
				e.st[k] = v
			end
		end
	end
	tI(elements, e)
	return e
end

elements = {}

-- ADD ELEMENTS HERE
-- time=0
-- addElement({x=1, y=1, t="A", cf=function(b) outB(2,true) end})
-- addElement({x=2, y=1, t="B", cf=function(b) outB(2,false) end})
-- addElement({x=3, y=1, h=2, t="CW", tg=false})
-- addElement({x=1, y=3, w=2, t="TX", tg=false,
-- 	uf=function(b) outB(1,b.tg) end -- Output true on channel if button is toggled
-- })
-- addElement({x=1, y=4, w=4,
-- 	uf=function(b)
-- 		time = time+0.016
-- 		b.fillHeight = math.abs(math.sin(time))
-- 	end
-- })
-- addElement({x=1, y=5, w=4,t="label"})

function clickB(b) if b.cf then b:cf() end end

function toggleB(b) if b.tg ~= nil then b.tg = not b.tg end end

function radioB(b) if b.ri ~= nil then
		for _, b2 in pairs(elements) do
			if b2.ri == b.ri and b2.rt then
				b2.rt = false
				clickB(b2)
			end
		end
		b.rt = true
	end
end

isTouched = false
touchedThisFrame = false
releasedThisFrame = false

function tickUI()
	tx, ty = getN(3, 4)
	touch = getB(1)
	touchedThisFrame = touch and not isTouched
	releasedThisFrame = isTouched and not touch
	isTouched = touch
	for _, b in pairs(elements) do
		if b.p ~= nil then
			if inRect(tx, ty, tU(getRect(b), 1, 4)) then
				if isTouched and not b.p then
					toggleB(b)
					radioB(b)
					clickB(b)
				end
				b.p = isTouched
			end
			if not isTouched and b.p then
				b.p = false
			end
			if b.p and b.hf then
				b:hf()
			end
		end
		if b.uf then
			b:uf()
		end
	end
end

function drawUI()
	if backgroundColor ~= nil then
		backgroundColor()
		dRF(0, 0, screen.getWidth(), screen.getHeight())
	end
	for k, b in pairs(elements) do
		local s = b.st;
		if b.p then
			s.p()
		elseif b.tg or b.rt then
			s.tg()
		else
			s.bg()
		end
		local r = getRect(b)
		if s.drawBG then 
			dRF(tU(r, 1, 4))
		end
		if b.fillHeight ~= nil or b.fillWidth ~= nil then
			local fr = getRect(b, true)
			s.tg()
			dRF(tU(fr, 1, 4))
		end
		local txt = { tU(r) }
		txt[1] = txt[1] + s.txo
		txt[2] = txt[2] + s.tyo
		tI(txt, b.t)
		tI(txt, s.ha)
		tI(txt, s.va)
		s.fg()
		dTB(tU(txt, 1, 7))
		if s.drawBorder then
			s.bdr()
			dR(tU(r, 1, 4))
		end
	end
end

---@endsection
