-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
local averageTime = property.getNumber("Average Time In Seconds")
local samplesPerSecond = 60
local maxTicks = averageTime * samplesPerSecond

lb_copy = function(from, to, overwrite)
	to = to or {}
	for k, v in pairs(from) do
		to[k] = not overwrite and to[k] or v -- underwrites, so the original values are kept if they existed
	end
	return to
end;

---@class LBRollingAverage
---@field maxValues number number of values this rolling average holds
---@field values number[] list of values to be averaged
---@field average number current average of the values that have been added
---@field count number number of values currently being averaged
---@field sum number total of the currently tracked values
LBRollingAverage = {

	---@param cls LBRollingAverage
	---@param maxValues number number of values this rolling average holds
	---@return LBRollingAverage
	new = function(cls, maxValues)
		return lb_copy(cls, {
			values = {},
			maxValues = maxValues or math.maxinteger,
			index = 1
		})
	end,

	---Add a value to the rolling average
	---@param self LBRollingAverage
	---@param value number value to add into the rolling average
	---@return number average the current rolling average (also accessible via .average)
	lbrollingaverage_addValue = function(self, value)
		self.values[(self.index % self.maxValues) + 1] = value
		self.index = self.index + 1
		self.count = math.min(self.index, self.maxValues)
		self.sum = 0
		for _, v in ipairs(self.values) do self.sum = self.sum + v end
		self.average = self.sum / self.count
		return self.average
	end,

	---Update the max values of the rolling average
	---@param self LBRollingAverage
	---@param maxValues number number of values this rolling average holds
	updateMaxValues = function(self, maxValues)
		if maxValues == self.maxValues then return end
		self.maxValues = maxValues
		self.values = {}
		self.index = 1
	end
}

local average = LBRollingAverage:new(maxTicks)
function onTick()
	local number = input.getNumber(1)
	local avgTime = input.getNumber(2)
	if avgTime ~= 0 then average:updateMaxValues(avgTime * samplesPerSecond) end
	local avg = average:lbrollingaverage_addValue(number)
	output.setNumber(1, avg)
end
