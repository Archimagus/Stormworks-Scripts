--- Runs after each file has been combined and minimized
--- Provides a chance to use the output, e.g. sending files into vehicle XML or similar
---@param rootPath Filepath         filepath to the root folder of the project
---@param name string               the name of the script that was built
---@param inputFile Filepath        filepath to the file that was just built
---@param minimizedText string      the minimized output text of the file that was just built
---@param inputText string          the text of the input file
---@param combinedText string       the text of the input file and all its dependencies
function onLBBuildFileComplete(rootPath, name, inputFile, minimizedText, inputText, combinedText)
	if name == "DrillShip.lua" then
		targetPath = LifeBoatAPI.Tools.Filepath:new(
			"D:/repos/Stormworks/Workspace/Tippy Shippy/Drill Rig MC/19/script.lua")
		LifeBoatAPI.Tools.FileSystemUtils.writeAllText(targetPath, minimizedText)
	end
end
