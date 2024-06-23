--- Runs after each file has been combined and minimized
--- Provides a chance to use the output, e.g. sending files into vehicle XML or similar
---@param rootPath Filepath         filepath to the root folder of the project
---@param name string               the name of the script that was built
---@param inputFile Filepath        filepath to the file that was just built
---@param minimizedText string      the minimized output text of the file that was just built
---@param inputText string          the text of the input file
---@param combinedText string       the text of the input file and all its dependencies
function onLBBuildFileComplete(rootPath, name, inputFile, minimizedText, inputText, combinedText, a, b, c)
	-- if name == "DrillShip\\DrillShip.lua" then
	-- 	targetPath = LifeBoatAPI.Tools.Filepath:new(
	-- 		"D:/repos/Stormworks/Workspace/Tippy Shippy/Drill Rig MC/19/script.lua")
	-- 	LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	-- 	os.execute('clip < \"' .. targetPath:win() .. '\"')
	-- end
	-- if name == "DrillShip\\DrillShipUI.lua" then
	-- 	targetPath = LifeBoatAPI.Tools.Filepath:new(
	-- 		"D:/repos/Stormworks/Workspace/Tippy Shippy/Drill Rig MC/116/script.lua")
	-- 	LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	-- end
	-- if name == "DrillShip\\DrillShipBitIndicator.lua" then
	-- 	targetPath = LifeBoatAPI.Tools.Filepath:new(
	-- 		"D:/repos/Stormworks/Workspace/Tippy Shippy/Drill Bit Display MC/37/script.lua")
	-- 	LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	-- end
	if name == "CVT.lua" then
		targetPath = LifeBoatAPI.Tools.Filepath:new(
			"D:/repos/Stormworks/Workspace/Starter Tanker Truck/CVT MC/23/script.lua")
		LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	end
	if name == "CarThrottle.lua" then
		targetPath = LifeBoatAPI.Tools.Filepath:new(
			"D:/repos/Stormworks/Workspace/Starter Tanker Truck/Car Throttle 2 MC/56/script.lua")
		LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	end
end
