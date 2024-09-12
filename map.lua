zoom = 40
sin, cos, pi, abs = math.sin, math.cos, math.pi, math.abs

getNr = input.getNumber
setNr = output.setNumber
setBl = output.setBool

drwCircle = screen.drawCircle
drwLine = screen.drawLine
drwRect = screen.drawRect
drwRectF = screen.drawRectF
drwText = screen.drawText

colr = screen.setColor

function onTick()
	inX = getNr(3)
	inY = getNr(4)
	isPrsd = input.getBool(1)

	setNr(14, zoom)
end

function inRect(rX, rY, rW, rH)
	return inX >= rX and inY >= rY and inX <= rX + rW and inY <= rY + rH
end

function onDraw()
	local screenW = screen.getWidth()
	local screenH = screen.getHeight()

	--bars
	colr(10, 10, 10)
	drwRectF(0, 0, 12, screenH)
	drwRectF(screenW - 12, 0, 12, screenH)

	--Draw zoom
	if isPrsd and inRect(2, 2, 7, 8) then
		zoom = zoom - 0.4
		colr(100, 100, 150)
		drwRectF(2, 2, 7, 8)
	end
	colr(200, 200, 255)
	drwRect(2, 2, 7, 8)
	drwText(4, 4, "+")
	if isPrsd and inRect(2, screenH - 10, 7, 8) then
		zoom = zoom + 0.4
		colr(100, 100, 150)
		drwRectF(2, screenH - 10, 7, 8)
	end
	colr(200, 200, 255)
	drwRect(2, screenH - 10, 7, 8)
	drwText(4, screenH - 8, "-")
	-- selector
	if zoom > 50 then zoom = 50 end
	if zoom < 1 then zoom = 1 end
	drwRect(2, 12, 7, screenH - 24)
	colr(255, 0, 0)
	drwRect(3, 11 + zoom / 50 * (screenH - 26), 5, 1)
end
