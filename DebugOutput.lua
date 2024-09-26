-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
local input1 = 0
local input2 = 0
local input3 = 0
local input4 = 0
local input5 = 0


function onTick()
	input1 = input.getNumber(1)
	input2 = input.getNumber(2)
	input3 = input.getNumber(3)
	input4 = input.getNumber(4)
	input5 = input.getNumber(5)
end

function onDraw()
	screen.drawText(0, 0, "In Pitch  : " .. string.format("%.2f", input1))
	screen.drawText(0, 10, "Out Pitch L: " .. string.format("%.2f", input2))
	screen.drawText(0, 20, "Out Pitch R: " .. string.format("%.2f", input3))
end
