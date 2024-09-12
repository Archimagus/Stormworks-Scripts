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

spindleLock = false
spindleUp = false
spindleDown = false
slurryPump = false
drillSpeed = 0

rackIndex = 1
indexBit = 0
prevIndexBit = 0
rackOffset = 1.5
rackTargetPosition = 0
targetPositions = {
    0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0
}
function incrementRack(count)
    rackIndex = (rackIndex + count)
    if rackIndex < 1 then
        rackIndex = #targetPositions
    elseif rackIndex > #targetPositions then
        rackIndex = 1
    end
    rackTargetPosition = targetPositions[rackIndex]
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
        incrementRack(1)
        return GrabberStates.PositionPipe
    end
    if (s.ticks > 200) then
        return GrabberStates.GrabberStuck
    end
end
positionPipeState = function(s)
    gripperRailUp = false
    gripperRailDown = true

    if s.ticks < 60 then
        adjustGripperUpButton = true
    end
    if s.ticks > 30 then
        gripperAngle = -1
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
    if spindleRailPosition <= -0.25 or (spindleRailPosition <= -0.3 and not drillToggle) then
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
    if spindleClamped then
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
    adjustGripperDownButton, adjustGripperUpButton, adjustJoinerDownButton, adjustJoinerUpButton,
    rackLeftButton, rackRightButton, rackIndexLeftButton, rackIndexRightButton, connectorJoinButton,
    gripperClamped, connectorClamped, connectorAligned, spindleClamped = getB(1, 2,
        3, 4, 5, 6,
        7, 8, 9, 10, 11,
        12, 13,
        14, 15, 16, 17)

    rackPosition, gripperRailPosition, spindleRailPosition =
        getN(1, 2, 3)

    grabPipeTransition = grabPipePulse:check(grabPipeButton)

    if drillButtonPulse:check(drillButton) then
        drillToggle = not drillToggle
    end

    grabberMachine:onTick()
    drillMachine:onTick()

    if (rackIndexRightButton) then
        indexBit = 1
    elseif (rackIndexLeftButton) then
        indexBit = -1
    else
        indexBit = 0
    end
    if indexBit ~= prevIndexBit then
        prevIndexBit = indexBit
        incrementRack(indexBit)
    end

    rackTargetPosition = ArchRampNumber(rackTargetPosition, rackRightButton, rackLeftButton, 0.0001, true)
    local rackVelocity = (rackTargetPosition + rackOffset - rackPosition) * 5

    gripperPipeVelocity = ArchRampNumber(gripperPipeVelocity, adjustGripperUpButton, adjustGripperDownButton)
    joinerPipeVelocity = ArchRampNumber(joinerPipeVelocity, adjustJoinerUpButton, adjustJoinerDownButton)


    outB(1, gripperRailUp, gripperRailDown, gripperClamp, connectorJoinButton, spindleUp, spindleDown, spindleLock,
        slurryPump)
    outN(1, gripperAngle, gripperPipeVelocity, joinerPipeVelocity, drillSpeed, rackVelocity)

    -- Outputs for other scripts or for across the composite
    outN(20,
        drillMachine.currentStateId,
        grabberMachine.currentStateId,
        rackIndex,
        rackPosition,
        rackTargetPosition)
end
