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


--- default onTick function; called once per in-game tick (60 per second)
ticks = 0
function onTick()
    ticks = ticks + 1
    output.setNumber(1, ticks)
    zoom = math.sin(ticks/60.0)
    output.setNumber(2, zoom)
end

--- default onDraw function; called once for each monitor connected each tick, order is not guaranteed
function onDraw()
	-- when you simulate, you should see a slightly pink circle growing over 10 seconds and repeating.
	screen.setColor(255, 125, 125)
	screen.drawMap(zoom*1000, 16, math.abs(zoom)*50)
end


--- Ready to put this in the game?
--- Just hit F7 and then copy the (now tiny) file from the /out/ folder

