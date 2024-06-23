require("Utils")

function onTick()
	bits = table.pack(getB(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
		27, 28,
		29, 30, 31, 32))
	current = getN(22)
	current = math.max(1, current)
end

function onDraw()
	local SCREEN_WIDTH = screen.getWidth()
	local spacing = (SCREEN_WIDTH - 16) / #bits
	print('spacing ' .. tostring(spacing))
	local w = spacing * 0.7
	for i = 1, #bits do
		local bit = bits[i]
		local x = (i * spacing)
		local y = 2
		if (bit) then
			ArchGreen()
			screen.drawRectF(x, y, w, w)
		else
			ArchRed()
			screen.drawRect(x, y, w, w)
		end
		if i == current then
			drawIndicator(x + w / 2, y + w)
		end
	end
end

function drawIndicator(cx, cy)
	ArchWhite()
	screen.drawTriangleF(-3.5 + cx, 7 + cy, 0 + cx, 0 + cy, 3.5 + cx, 7 + cy)
end
