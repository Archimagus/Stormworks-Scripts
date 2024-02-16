---@diagnostic disable: duplicate-doc-field
require("Utils.MyIoUtils")

drawTextBox = screen.drawTextBox
drawRect = screen.drawRect
drawFilledRect = screen.drawRectF
-- sC = screen.setColor
sC = function(r, g, b)
	screen.setColor(r, g, b)
end


---@section print
print = print or LifeBoatAPI.lb_doNothing
---@endsection

---@section inRect
function inRect(x, y, a, b, w, h) return x > a and y > b and x < a + w and y < b + h end

---@endsection

---@section ArchBlack
function ArchBlack() sC(0, 0, 0) end

---@endsection
---@section ArchWhite
function ArchWhite() sC(255, 255, 255) end

---@endsection

---@section ArchRed
function ArchRed() sC(255, 0, 0) end

---@endsection

---@section ArchLime
function ArchLime() sC(0, 255, 0) end

---@endsection

---@section ArchBlue
function ArchBlue() sC(0, 0, 255) end

---@endsection

---@section ArchYellow
function ArchYellow() sC(255, 255, 0) end

---@endsection

---@section ArchCyan
function ArchCyan() sC(0, 255, 255) end

---@endsection

---@section ArchMagenta
function ArchMagenta() sC(255, 0, 255) end

---@endsection

---@section ArchSilver
function ArchSilver() sC(192, 192, 192) end

---@endsection

---@section ArchGray
function ArchGray() sC(128, 128, 128) end

---@endsection

---@section ArchDarkGray
function ArchDarkGray() sC(32, 32, 32) end

---@endsection

---@section ArchMaroon
function ArchMaroon() sC(128, 0, 0) end

---@endsection

---@section ArchOlive
function ArchOlive() sC(128, 128, 0) end

---@endsection

---@section ArchGreen
function ArchGreen() sC(0, 128, 0) end

---@endsection

---@section ArchPurple
function ArchPurple() sC(128, 0, 128) end

---@endsection

---@section ArchTeal
function ArchTeal() sC(0, 128, 128) end

---@endsection

---@section ArchNavy
function ArchNavy() sC(0, 0, 128) end

---@endsection

---@section ArchBrown
function ArchBrown() sC(165, 42, 42) end

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
	bg = ArchBlack,
	fg = ArchWhite,
	p = ArchDarkGray,
	tg = ArchGreen,
	bdr = ArchWhite,
	drawBorder = 2,
	drawBG = 2,
	ha = 0,
	va = 0,
	txo = 0,
	tyo = 0,
}
---@endsection

---@section getRect
function getRect(b, fw, fh)
	return { b.x * (gridX + gridXSpace)
	, b.y * (gridY + gridYSpace)
	, b.w * gridX * (fw or 1)
	, b.h * gridY * (fh or 1) }
end

---@endsection

---@section addElement
---@type table<number, MyElement>
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
	if backgroundColor then
		backgroundColor()
		drawFilledRect(0, 0, screen.getWidth(), screen.getHeight())
	end

	for k, b in pairs(elements) do
		localState = b.st;
		drawUI_LocalRect = getRect(b)
		if shouldDraw(localState.drawBG, b) then
			if b.p then
				localState.p()
			elseif b.tg or b.rt then
				localState.tg()
			else
				localState.bg()
			end
			drawFilledRect(tU(drawUI_LocalRect, 1, 4))
		end

		if b.fillHeight or b.fillWidth then
			drawUiFillRect = getRect(b, b.fillWidth, b.fillHeight)
			localState.tg()
			drawFilledRect(tU(drawUiFillRect, 1, 4))
		end
		drawUiText = { tU(drawUI_LocalRect) }
		drawUiText[1] = drawUiText[1] + localState.txo
		drawUiText[2] = drawUiText[2] + localState.tyo
		tI(drawUiText, b.t)
		tI(drawUiText, localState.ha)
		tI(drawUiText, localState.va)
		localState.fg()
		drawTextBox(tU(drawUiText, 1, 7))
		if shouldDraw(localState.drawBorder, b) then
			localState.bdr()
			drawRect(tU(drawUI_LocalRect, 1, 4))
		end
	end
end

---@function shouldDraw
---@param check number 0 never, 1 on press, 2 always
---@param b MyElement
function shouldDraw(check, b)
	return (check == 2 or (check == 1 and (b.p or b.tg or b.rt))) == true
end

---@endsection
