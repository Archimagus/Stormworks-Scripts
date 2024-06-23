-- DrillShip.lua
-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--[====[ HOTKEYS ]====]
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA

-- require("LifeBoatAPI.Tickable.LBTouchScreen")


require("DrillShip.DrillStates")
require("Utils")
require("LifeBoatAPI")


gripperRailUp = false
gripperRailDown = false
gripperAngle = 1
gripperPipeVelocity = 0
joinerPipeVelocity = 0
gripperClamp = false

lockWellHead = true
spindleLock = false
spindleUp = false
spindleDown = false
slurryPump = false
drillSpeed = 0

barrelIndex = 0
indexBit = 0
prevIndexBit = 0
targetPositions = {
    0, 0.028, 0.0558, 0.087777, 0.115, 0.165, 0.191, 0.22, 0.25, 0.277777,
    0.307, 0.336, 0.362, 0.4166, 0.444444, 0.47, 0.5, 0.527777, 0.555555, 0.585,
    0.615, 0.666, 0.694, 0.722222, 0.75, 0.777777, 0.805555, 0.835, 0.863, 0.916,
    0.9444, 0.972222
}
function incrementBarrel(count)
    barrelIndex = (barrelIndex + count)
    if barrelIndex < 1 then
        barrelIndex = #targetPositions
    elseif barrelIndex > #targetPositions then
        barrelIndex = 1
    end
    barrelTarget = targetPositions[barrelIndex]
end

grabberWatchState = function()
    gripperAngle = -1
    gripperRailDown = false
    gripperRailUp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailUp = true
    end
    if (grabPipeTransition) then
        incrementBarrel(1)
        return GrabberStates.GrabPipe
    end
end
grabberStuckState = function()
    gripperAngle = 1
    gripperClamp = false
    gripperRailDown = false
    gripperRailUp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailUp = false
    end
    if grabPipeTransition then
        return GrabberStates.GrabPipe
    end
end
grabPipeState = function(s)
    gripperAngle = 1
    gripperClamp = true
    if s.ticks > 90 then
        gripperRailUp = true
    end
    if (gripperClamped) then
        return GrabberStates.PositionPipe
    end
    if (gripperRailPosition > 0.49 or s.ticks > 200) then
        return GrabberStates.GrabberStuck
    end
end
positionPipeState = function(s)
    gripperRailUp = false
    gripperRailDown = true
    gripperAngle = -1

    if s.ticks < 60 then
        adjustGripperRightButton = true
    end

    if grabPipeTransition then
        return GrabberStates.Watch
    end
    if spindleClamped then
        gripperClamp = false
        return GrabberStates.Watch
    end
end

drillState = function()
    if spindleRailPosition <= -0.304 or (spindleRailPosition <= -0.3 and not drillToggle) then
        drillToggle = false
        spindleLock = false
        return DrillStates.DrillRetract
    end
    if not drillToggle then
        drillToggle = false
        return DrillStates.DrillRetract
    end

    spindleLock = true
    spindleDown = true
    spindleUp = false
    if spindleClamped and wellHeadLocked then
        slurryPump = true
        drillSpeed = 1
    else
        slurryPump = false
        drillSpeed = 0
    end
end

drillRetractState = function()
    spindleUp = true
    spindleDown = false
    slurryPump = false
    drillSpeed = 0

    if drillToggle then
        return DrillStates.Drill
    end
end


grabberMachine = ArchStateMachine:new(GrabberStates.Watch, grabberWatchState)
grabberMachine:addState(GrabberStates.GrabberStuck, grabberStuckState)
grabberMachine:addState(GrabberStates.GrabPipe, grabPipeState)
grabberMachine:addState(GrabberStates.PositionPipe, positionPipeState)

drillMachine = ArchStateMachine:new(DrillStates.DrillRetract, drillRetractState)
drillMachine:addState(DrillStates.Drill, drillState)


drillButtonPulse = ArchPulse:new()
grabPipePulse = ArchPulse:new()
function onTick()
    grabPipeButton, drillButton,
    adjustGripperLeftButton, adjustGripperRightButton, adjustJoinerLeftButton, adjustJoinerRightButton,
    barrelLeftButton, barrelRightButton, barrelIndexLeftButton, barrelIndexRightButton, connectorJoinButton,
    bitWinchDownButton, bitWinchUpButton,
    gripperClamped, connectorClamped, connectorAligned, spindleClamped, wellHeadLocked = getB(1, 2,
        3, 4, 5, 6,
        7, 8, 9, 10, 11,
        12, 13,
        14, 15, 16, 17, 32)

    barrelAngle, gripperRailPosition, spindleRailPosition, headWinchPosition, bitDistance =
        getN(1, 2, 3, 4, 5)

    grabPipeTransition = grabPipePulse:check(grabPipeButton)

    if drillButtonPulse:check(drillButton) then
        drillToggle = not drillToggle
    end

    grabberMachine:onTick()
    drillMachine:onTick()

    if (barrelIndexRightButton) then
        indexBit = 1
    elseif (barrelIndexLeftButton) then
        indexBit = -1
    else
        indexBit = 0
    end
    if indexBit ~= prevIndexBit then
        prevIndexBit = indexBit
        incrementBarrel(indexBit)
    end

    barrelTarget = ArchRampNumber(barrelTarget, barrelRightButton, barrelLeftButton, 0.0001, true)
    local barrelVelocity = (barrelTarget - barrelAngle) * 10

    gripperPipeVelocity = ArchRampNumber(gripperPipeVelocity, adjustGripperRightButton, adjustGripperLeftButton)
    joinerPipeVelocity = ArchRampNumber(joinerPipeVelocity, adjustJoinerRightButton, adjustJoinerLeftButton)

    if not wellHeadLocked then
        bitWinchDown = drillMachine.currentStateId == DrillStates.Drill and bitDistance > headWinchPosition - 0.1
    else
        bitWinchDown = false
    end

    outB(1, gripperRailUp, gripperRailDown, gripperClamp, connectorJoinButton, spindleUp, spindleDown, spindleLock,
        slurryPump, bitWinchDown or bitWinchDownButton, bitWinchUpButton)
    outN(1, gripperAngle, gripperPipeVelocity, joinerPipeVelocity, drillSpeed, barrelVelocity)

    -- Outputs for other scripts or for across the composite
    outN(20,
        drillMachine.currentStateId,
        grabberMachine.currentStateId,
        barrelIndex,
        barrelAngle,
        barrelTarget)
    outB(31, lockWellHead)
end

-- function onDraw()
--     ArchMaroon()
--     local spacing = 7
--     screen.drawText(150, 0 * spacing, "bitWinchDown: " .. tostring(grabPipeButton))
--     screen.drawText(150, 1 * spacing, "drillState: " .. tostring(drillMachine.currentStateId))
--     screen.drawText(150, 2 * spacing, "bitDistance: " .. string.format("%.2f", bitDistance))
--     screen.drawText(150, 3 * spacing, "headWinchPosition: " .. string.format("%.2f", headWinchPosition))
-- end
