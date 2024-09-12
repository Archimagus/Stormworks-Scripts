require("Utils.MyIoUtils")
require("Utils.MyUITools")
require("DrillShip.DrillStates")

grabPipeButton = addElement({ x = 6, y = 3, w = 4, t = "Grab", p = false })
mergeButton = addElement({ x = 11, y = 4, w = 2, h = 5, t = "Join", p = false, st = { drawBG = 1 } })
drillButton = addElement({ x = 6, y = 9, w = 4, t = "Drill", tg = false })
adjustGripperUpButton = addElement({ x = 11.5, y = 3, w = 1, t = "^", p = false, fg = ArchBlack, bg = ArchBrown })
adjustGripperDownButton = addElement({ x = 11.5, y = 9, w = 1, t = "V", p = false, fg = ArchBlack, bg = ArchBrown })
adjustJoinerUpButton = addElement({ x = 10, y = 3, w = 1, t = "^", p = false, fg = ArchBlack, bg = ArchGreen })
adjustJoinerDownButton = addElement({ x = 10, y = 9, w = 1, t = "V", p = false, fg = ArchBlack, bg = ArchGreen })

-- drillDepthLabel = addElement({ x = 0, y = 11, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
-- wellDepthLabel = addElement({ x = 0, y = 12, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
-- bitDepthLabel = addElement({ x = 8, y = 11, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
-- winchLabel = addElement({ x = 8, y = 12, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })


barrelIndexLeftButton = addElement({ x = 0, y = 2, w = 1, t = "<<", p = false })
barrelLeftButton = addElement({ x = 1, y = 2, w = 1, t = "<", p = false })
barrelRightButton = addElement({ x = 2, y = 2, w = 1, t = ">", p = false })
barrelIndexRightButton = addElement({ x = 3, y = 2, w = 1, t = ">>", p = false })


function onTick()
	connectorClamped,
	connectorAligned,
	wellHeadLocked                  = getB(2, 3, 32)

	headWinchPosition,
	bitDistance,
	drillState,
	grabberState,
	rackIndex,
	rackPosition,
	rackTargetPosition,
	drillDepth,
	wellDepth                       = getN(5, 6, 7, 8, 9, 10, 11, 31, 32)

	drillButton.tg                  = drillState ~= DrillStates.DrillRetract
	drillButton.t                   = drillButton.tg and "Retract" or "Drill"

	mergeButton.t                   = connectorAligned and "Join" or ""
	mergeButton.st.fg               = connectorAligned and ArchGreen or ArchGray

	grabPipeButton.t                = grabberState == GrabberStates.GrabPipe and "Retract" or "Grab"
	grabPipeButton.visible          = drillState == DrillStates.DrillRetract

	mergeVisisble                   = grabberState == GrabberStates.PositionPipe
	mergeButton.visible             = mergeVisisble
	adjustGripperDownButton.visible = mergeVisisble
	adjustGripperUpButton.visible   = mergeVisisble

	adjustJoinerDownButton.visible  = connectorClamped and drillState == DrillStates.DrillRetract
	adjustJoinerUpButton.visible    = connectorClamped and drillState == DrillStates.DrillRetract

	-- winchLabel.t                     = "Winch:" .. string.format("%.2f", headWinchPosition) .. "m"
	-- bitDepthLabel.t                  = "Bit  :" .. string.format("%.2f", bitDistance) .. "m"
	-- drillDepthLabel.t                = "Drill Depth:" .. string.format("%.2f", drillDepth) .. "m"
	-- wellDepthLabel.t                 = " Well Depth:" .. string.format("%.2f", wellDepth) .. "m"


	tickUI()

	outB(1,
		grabPipeButton.p,
		drillButton.p,
		adjustGripperDownButton.p,
		adjustGripperUpButton.p,
		adjustJoinerDownButton.p,
		adjustJoinerUpButton.p,
		barrelLeftButton.p,
		barrelRightButton.p,
		barrelIndexLeftButton.p,
		barrelIndexRightButton.p,
		mergeButton.p
	)
	outB(32, wellHeadLocked)
end

function onDraw()
	drawUI()
end
