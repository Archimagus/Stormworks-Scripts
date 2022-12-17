-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
-- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey (Please retain this notice at the top of the file as a courtesy; a lot of effort went into the creation of these tools.)
--- With LifeBoatAPI; you can use the "require(...)" keyword to use code from other files!
---     This lets you share code between projects, and organise your work better.
---     The below, includes the content from SimulatorConfig.lua in the generated /_build/ folder
--- (If you want to include code from other projects, press CTRL+COMMA, and add to the LifeBoatAPI library paths)

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

afr=0.502
run=false

function onTick()
	diff = input.getNumber(1)
	on = input.getBool(1)
	if(run ~= on) then
		afr = 0.502
		run = on
	end

	if run then
		if math.abs(diff) > 0.2 then
			afr = afr + 0.001 * -sign(diff)
		elseif math.abs(diff) > 0.1 then
			afr = afr + 0.0005 * -sign(diff)
		elseif math.abs(diff) > 0.05 then
			afr = afr + 0.0001 * -sign(diff)
		else
			afr = afr + 0.00001 * -sign(diff)
		end

		output.setNumber(1, afr)
	end
end


--- Ready to put this in the game?
--- Just hit F7 and then copy the (now tiny) file from the /out/ folder

