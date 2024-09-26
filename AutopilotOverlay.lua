--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
	---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
	simulator = simulator
	simulator:setScreen(1, "3x2")
	simulator:setProperty("Distance Units", 1)

	-- Runs every tick just before onTick allows you to simulate the inputs changing
	---@param simulator Simulator Use simulator:<function>() to set inputs etc.
	---@param ticks     number Number of ticks since simulator started
	function onLBSimulatorTick(simulator, ticks)
		simulator:setInputBool(1, simulator:getIsToggled(1))
		simulator:setInputBool(2, simulator:getIsToggled(2))
		simulator:setInputNumber(4, simulator:getSlider(1) * 500)
		simulator:setInputNumber(5, simulator:getSlider(2) * 3000)
	end
end
---@endsection


local distanceUnits = property.getNumber("Distance Units")
-- 0 = metric, 1 = imperial, 2 = knots
local distanceString = ""
local timeString = ""
local holdPosition = false
local goToPosition = false

function onTick()
	holdPosition = input.getBool(1)
	goToPosition = input.getBool(2)

	local etaInSeconds = input.getNumber(4)
	local distanceToTargetInMeters = input.getNumber(5)
	local etaMinutes = math.floor(etaInSeconds / 60)
	local etaSeconds = math.floor(etaInSeconds % 60)
	timeString = etaMinutes .. ":" .. etaSeconds

	if distanceUnits == 0 then
		if distanceToTargetInMeters > 999 then
			distanceString = string.format("%.2f", distanceToTargetInMeters / 1000) .. "km"
		else
			distanceString = string.format("%.1f", distanceToTargetInMeters) .. "m"
		end
	elseif distanceUnits == 1 then
		local distanceInFeet = distanceToTargetInMeters * 3.28084
		if distanceInFeet > 999 then
			distanceString = string.format("%.2f", distanceToTargetInMeters / 1609.34) .. "mi"
		else
			distanceString = string.format("%.1f", distanceInFeet) .. "ft"
		end
	elseif distanceUnits == 2 then
		local distanceInFeet = distanceToTargetInMeters * 3.28084
		if distanceInFeet > 999 then
			distanceString = string.format("%.2f", distanceToTargetInMeters / 1852) .. "nm"
		else
			distanceString = string.format("%.1f", distanceInFeet) .. "ft"
		end
	end
end

function onDraw()
	local height = screen.getHeight()
	-- Semi-transparent black background
	screen.setColor(0, 0, 0, 200)
	if holdPosition then
		screen.drawRectF(0, height - 14, screen.getWidth(), 14)
		-- Teal color for hold position mode
		screen.setColor(0, 204, 204)
	elseif goToPosition then
		screen.drawRectF(0, height - 14, screen.getWidth(), 14)
		-- Orange color for go to position mode
		screen.setColor(255, 165, 0)
	else
		return
	end


	screen.drawText(1, height - 6, "ETA: " .. timeString)
	screen.drawText(1, height - 12, "DST: " .. distanceString)
end
