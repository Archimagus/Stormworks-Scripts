require("Utils.MyIoUtils")

drawTextBox = screen.drawTextBox
drawRect = screen.drawRect
drawFilledRect = screen.drawRectF
print = print or LifeBoatAPI.lb_doNothing

---@section setColor
---@param color table {r, g, b, a|nil}
function setColor(color)
	color[4] = color[4] or 255
	screen.setColor(tU(color, 1, 4))
end

---@endsection

---@section inRect
function inRect(x, y, a, b, w, h) return x > a and y > b and x < a + w and y < b + h end

---@endsection

---@section Arch_Black
Arch_Black = { 0, 0, 0 }

---@endsection
---@section Arch_White
Arch_White = { 255, 255, 255 }

---@endsection

---@section Arch_Red
Arch_Red = { 255, 0, 0 }

---@endsection

---@section Arch_Lime
Arch_Lime = { 0, 255, 0 }

---@endsection

---@section Arch_Blue
Arch_Blue = { 0, 0, 255 }

---@endsection

---@section Arch_Yellow
Arch_Yellow = { 255, 255, 0 }

---@endsection

---@section Arch_Cyan
Arch_Cyan = { 0, 255, 255 }

---@endsection

---@section Arch_Magenta
Arch_Magenta = { 255, 0, 255 }

---@endsection

---@section Arch_Silver
Arch_Silver = { 192, 192, 192 }

---@endsection

---@section Arch_Gray
Arch_Gray = { 128, 128, 128 }

---@endsection

---@section Arch_DarkGray
Arch_DarkGray = { 32, 32, 32 }

---@endsection

---@section Arch_Maroon
Arch_Maroon = { 128, 0, 0 }

---@endsection

---@section Arch_Olive
Arch_Olive = { 128, 128, 0 }

---@endsection

---@section Arch_Green
Arch_Green = { 0, 128, 0 }

---@endsection

---@section Arch_Purple
Arch_Purple = { 128, 0, 128 }

---@endsection

---@section Arch_Teal
Arch_Teal = { 0, 128, 128 }

---@endsection

---@section Arch_Navy
Arch_Navy = { 0, 0, 128 }

---@endsection

---@section Arch_Brown
Arch_Brown = { 165, 42, 42 }

---@endsection


---@section baseStyle
w = 0
h = 0
gridX = 12
gridY = 12
gridXSpace = 0
gridYSpace = 0
backgroundColor = nil -- screen backgroundColor

---@class baseStyle
---@field bg table {r,g,b} background color
---@field fg function foreground color function
---@field p function pressed color function
---@field tg function toggled color function
---@field bdr function border color function
---@field drawBorder number draw the background? 0 never, 1 on press, 2 always
---@field drawBG number draw the background? 0 never, 1 on press, 2 always
---@field ha number horizontal text alignment
---@field va number vertical text alignment
---@field txo number text X offset
---@field tyo number text Y offset

baseStyle = {
	bg = Arch_Black,
	fg = Arch_White,
	p = Arch_DarkGray,
	tg = Arch_Green,
	bdr = Arch_White,
	drawBorder = 2,
	drawBG = 2,
	ha = 0,
	va = 0,
	txo = 0,
	tyo = 0,
}
---@endsection

---@section getRect
function getRect(b, f)
	local r = { b.x * (gridX + gridXSpace), b.y * (gridY + gridYSpace), b.w * gridX, b.h * gridY }
	if f then
		r[3] = r[3] * (b.fillHeight or 1)
		r[4] = r[4] * (b.fillWidth or 1)
	end
	return r
end

---@endsection

---@section addElement
elements = {}

---@class MyElement
---@field x number x position in grid
---@field y number y position in grid
---@field w number width in grid cells
---@field h number height in grid cells
---@field t string text
---@field st baseStyle style override
---@field p boolean|nil pressed state (if nil, not a clickable element)
---@field tg boolean|nil current toggle state (if nil, not a toggle button)
---@field ri number|nil radio button index (if nil, not a radio button)
---@field rt boolean|nil radio toggled initial state (if nil, not a radio button)
---@field cf function|nil click function (if not nil will be clickable and called on click)
---@field hf function|nil optional hold function (if not nil will be clickable and called while held)
---@field uf function|nil optional update function (if not nil will be called every frame)

---@function addElement
---@param e table
---@return MyElement
function addElement(e)
	e.x = e.x or 0
	e.y = e.y or 0
	e.w = e.w or 1
	e.h = e.h or 1
	e.t = e.t or ""
	--e.st style override
	--e.tg  make button toggle
	--e.ri  radio button index
	--e.rt  radio toggled initial state
	--e.cf  click funtion
	--e.hf  hold funtion
	--e.uf  update function
	if e.tg ~= nil or e.cf or e.hf or e.ri then
		e.p = false -- make this a clickable element if any of the above are defined
	end

	e.st = LifeBoatAPI.lb_copy(baseStyle, e.st or {})

	tI(elements, e)
	return e
end

---@endsection


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

---@section clickB
function clickB(b) if b.cf then b:cf() end end

function toggleB(b) if b.tg ~= nil then b.tg = not b.tg end end

function radioB(b)
	if b.ri ~= nil then
		for _, b2 in pairs(elements) do
			if b2.ri == b.ri and b2.rt then
				b2.rt = false
				clickB(b2)
			end
		end
		b.rt = true
	end
end

---@endsection

---@section tickUI
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
			if not isTouched then
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

---@endsection

---@section drawUI
function drawUI()
	if backgroundColor ~= nil then
		backgroundColor()
		drawFilledRect(0, 0, screen.getWidth(), screen.getHeight())
	end

	for k, b in pairs(elements) do
		local s = b.st;
		local r = getRect(b)


		if shouldDraw(s.drawBG) then
			if b.p then
				setColor(s.p)
			elseif b.tg or b.rt then
				setColor(s.tg)
			else
				setColor(s.bg)
			end
			drawFilledRect(tU(r, 1, 4))
		end

		if b.fillHeight ~= nil or b.fillWidth ~= nil then
			local fr = getRect(b, true)
			setColor(s.tg)
			drawFilledRect(tU(fr, 1, 4))
		end
		local txt = { tU(r) }
		txt[1] = txt[1] + s.txo
		txt[2] = txt[2] + s.tyo
		tI(txt, b.t)
		tI(txt, s.ha)
		tI(txt, s.va)
		setColor(s.fg)
		drawTextBox(tU(txt, 1, 7))
		if shouldDraw(s.drawBorder) then
			setColor(s.bdr)
			drawRect(tU(r, 1, 4))
		end
	end

	function shouldDraw(check)
		return check == 2 or (check == 1 and (b.p or b.tg or b.rt))
	end
end

---@endsection
