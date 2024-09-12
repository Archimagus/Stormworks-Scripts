-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>


local minChanel = 100000
local minValue = 100000
local maxChanel = -100000
local maxValue = -100000
local channelValues = {}

local ticksPerSecond = 60
local tickRate = 1 / ticksPerSecond
function onTick()
	minChanel = 100000
	minValue = 100000
	maxChanel = -100000
	maxValue = -100000
	for i = 1, 31 do
		local channelValue = input.getNumber(i)
		if channelValue > 0 then
			if channelValues[i] == nil then
				channelValues[i] = {
					currentValue = 0,
					lastValue = 0,
				}
			end
			-- store the current value and the last value
			local lastValue = channelValues[i].currentValue or 0
			channelValues[i] = {
				currentValue = channelValue,
				lastValue = lastValue
			}
			if channelValue > maxValue then
				maxChanel = i
				maxValue = channelValue
			end
			if channelValue < minValue then
				minChanel = i
				minValue = channelValue
			end
		else
			-- delete the value from the table
			channelValues[i] = nil
		end
	end

	output.setNumber(1, maxChanel)
	output.setNumber(2, minChanel)
	output.setNumber(3, maxValue)
	output.setNumber(4, minValue)
end

function onDraw()
	local width = screen.getWidth()
	local height = screen.getHeight()
	screen.setColor(0, 0, 0)
	screen.drawClear()

	-- Get the number of active channels
	local numChanels = #channelValues

	local chanelWidth = width / numChanels
	local drawWidth = chanelWidth
	local margin = 0
	if chanelWidth > 3 then
		drawWidth = chanelWidth - 2
		margin = 1
	end

	for index, channel in ipairs(channelValues) do
		local value = channel.currentValue
		local lastValue = channel.lastValue

		screen.setColor(tempToColor(value))
		screen.drawRectF((index - 1) * chanelWidth + margin, height, drawWidth, -value)
		screen.setColor(75, 75, 75)
		screen.drawRect((index - 1) * chanelWidth, height, chanelWidth, height)

		-- Draw background box for text
		screen.setColor(0, 0, 0)
		screen.drawRectF((index - 1) * chanelWidth + margin + 1, height - 48, drawWidth - 2, 48)

		if index == maxChanel then
			screen.setColor(180, 0, 0)
		elseif index == minChanel then
			screen.setColor(0, 0, 180)
		else
			screen.setColor(180, 180, 180)
		end

		screen.drawTextBox((index - 1) * chanelWidth + margin + 1, height - 10, drawWidth, 10, index, 0, 0)
		-- roud value to 1 decimal place
		local current = math.floor(value * 10 + 0.5) / 10
		screen.drawTextBox((index - 1) * chanelWidth + margin + 1, height - 22, drawWidth, 10, current)

		local change = value - lastValue
		-- Change/Second
		change = change / tickRate

		local arrowSize = drawWidth / 2

		screen.drawTextBox((index - 1) * chanelWidth + margin + 1, height - 47, drawWidth - margin, 10,
			string.format("%+.3f", change))
		-- draw an up or down arrow if the value has changed
		if change > 0 then
			screen.setColor(180, 180, 0)
			screen.drawTriangleF(
				(index - 1) * chanelWidth + margin + drawWidth / 2 - arrowSize / 2, height - 30 + arrowSize / 2,
				(index - 1) * chanelWidth + margin + drawWidth / 2 + arrowSize / 2, height - 30 + arrowSize / 2,
				(index - 1) * chanelWidth + margin + drawWidth / 2, height - 30 - arrowSize / 2)
		elseif change < 0 then
			screen.setColor(0, 180, 180)
			screen.drawTriangleF(
				(index - 1) * chanelWidth + margin + drawWidth / 2 - arrowSize / 2, height - 30 - arrowSize / 2,
				(index - 1) * chanelWidth + margin + drawWidth / 2 + arrowSize / 2, height - 30 - arrowSize / 2,
				(index - 1) * chanelWidth + margin + drawWidth / 2, height - 30 + arrowSize / 2)
		end
	end

	screen.setColor(180, 180, 180)
	screen.drawTextBox(0, 0, width, 10, "Max Channel: " .. maxChanel .. ", " .. maxValue)
	screen.drawTextBox(0, 10, width, 10, "Min Channel: " .. minChanel .. ", " .. minValue)
end

function tempToPercent(temp)
	local maxTemp = 100
	local minTemp = 20
	return (temp - minTemp) / (maxTemp - minTemp)
end

-- Given a temperature, return a color from blue to red
function tempToColor(temp)
	local percent = clamp(tempToPercent(temp))
	local r = 0
	local g = 0
	local b = 0
	if percent < 0.5 then
		r = 0
		g = percent * 2 * 255
		b = 255 - g
	else
		r = (percent - 0.5) * 2 * 255
		g = 255 - r
		b = 0
	end
	return r, g, b
end

function clamp(number, min, max)
	min = min or 0
	max = max or 1
	return math.min(math.max(number, min), max)
end
