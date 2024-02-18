require("Utils")

barrelIndex = 0
targetPositions = {
	0, 0.027777, 0.0558, 0.087777, 0.115, 0.165, 0.192, 0.22, 0.25, 0.277777,
	0.307, 0.336, 0.362, 0.4166, 0.444444, 0.47, 0.5, 0.527777, 0.555555, 0.585,
	0.615, 0.666, 0.694, 0.722222, 0.75, 0.777777, 0.805555, 0.835, 0.863, 0.916,
	0.9444, 0.972222, 1
}

bitIndexLabel = addElement({ x = 2, y = 1, w = 16, t = "Bit:1", st = { drawBorder = 0, drawBG = 0, fg = ArchMaroon, ha = -1 } })

function incrementBarrel(count)
	barrelIndex = (barrelIndex + count)
	if barrelIndex < 1 then
		barrelIndex = #targetPositions
	elseif barrelIndex > #targetPositions then
		barrelIndex = 1
	end
	barrelTarget = targetPositions[barrelIndex]
end

prevIndexBit = 0
function onTick()
	barrelRight, barrelLeft = getB(21, 22)
	indexBit = getN(21)
	if indexBit ~= prevIndexBit then
		prevIndexBit = indexBit
		incrementBarrel(indexBit)
	end

	local barrelAngle = input.getNumber(20)
	barrelTarget = ArchRampNumber(barrelTarget, barrelRight, barrelLeft, 0.001, true)
	local barrelVelocity = (barrelTarget - barrelAngle) * 10

	bitIndexLabel.t = "Bit:" ..
		tostring(barrelIndex) ..
		"A:" ..
		string.format("%.3f", barrelAngle) ..
		"T:" .. string.format("%.3f", barrelTarget) .. "V:" .. string.format("%.1f", barrelVelocity)

	-- forward outputs from previous script
	outB(1, getB(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19))
	outN(1, getN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19))
	outB(30, getB(30, 31, 32))
	outN(30, getN(30, 31, 32))

	-- write our outputs
	outN(20, barrelVelocity)
end

function onDraw()
	drawUI()
end
