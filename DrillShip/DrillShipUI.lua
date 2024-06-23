require("Utils.MyIoUtils")
require("Utils.MyUITools")
require("DrillShip.DrillStates")

adjustJoinerLeftButton = addElement({ x = 4, y = 6, w = 1, t = "<", p = false })
adjustJoinerRightButton = addElement({ x = 5, y = 6, w = 1, t = ">", p = false })
grabPipeButton = addElement({ x = 6, y = 4, w = 5, t = "Grab", p = false })
mergeButton = addElement({ x = 6, y = 6, w = 5, t = "Join", p = false, st = { drawBG = 1 } })
drillButton = addElement({ x = 6, y = 8, w = 5, t = "Drill", tg = false })
adjustGripperLeftButton = addElement({ x = 11, y = 6, w = 1, t = "<", p = false })
adjustGripperRightButton = addElement({ x = 12, y = 6, w = 1, t = ">", p = false })

bitWinchUpButton = addElement({ x = 0, y = 6, w = 1, t = "^", p = false })
bitWinchDownButton = addElement({ x = 0, y = 7, w = 1, t = "v", p = false })

drillDepthLabel = addElement({ x = 0, y = 11, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
wellDepthLabel = addElement({ x = 0, y = 12, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
bitDepthLabel = addElement({ x = 8, y = 11, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })
winchLabel = addElement({ x = 8, y = 12, w = 8, st = { drawBorder = 0, ha = -1, fg = ArchMaroon } })


barrelIndexLeftButton = addElement({ x = 0, y = 2, w = 1, t = "<<", p = false })
barrelLeftButton = addElement({ x = 1, y = 2, w = 1, t = "<", p = false })
barrelRightButton = addElement({ x = 2, y = 2, w = 1, t = ">", p = false })
barrelIndexRightButton = addElement({ x = 3, y = 2, w = 1, t = ">>", p = false })

bitIndexLabel = addElement({ x = 5, y = 2, w = 16, t = "Bit:1", st = { drawBorder = 0, fg = ArchMaroon, ha = -1 } })


function onTick()
	connectorClamped,
	connectorAligned,
	wellHeadLocked                   = getB(2, 3, 32)

	headWinchPosition,
	bitDistance,
	drillState,
	grabberState,
	barrelIndex,
	barrelAngle,
	barrelTarget,
	drillDepth,
	wellDepth                        = getN(5, 6, 7, 8, 9, 10, 11, 31, 32)

	drillButton.tg                   = drillState ~= DrillStates.DrillRetract
	drillButton.t                    = drillButton.tg and "Retract" or "Drill"

	mergeButton.t                    = connectorAligned and "Join" or ""
	mergeButton.st.fg                = connectorAligned and ArchGreen or ArchGray

	grabPipeButton.t                 = grabberState == GrabberStates.GrabPipe and "Retract" or "Grab"
	grabPipeButton.visible           = drillState == DrillStates.DrillRetract

	mergeVisisble                    = grabberState == GrabberStates.PositionPipe
	mergeButton.visible              = mergeVisisble
	adjustGripperLeftButton.visible  = mergeVisisble
	adjustGripperRightButton.visible = mergeVisisble

	adjustJoinerLeftButton.visible   = connectorClamped and drillState == DrillStates.DrillRetract
	adjustJoinerRightButton.visible  = connectorClamped and drillState == DrillStates.DrillRetract

	bitIndexLabel.t                  = "Bit:" ..
		string.format("%d", barrelIndex) ..
		"A:" ..
		string.format("%.3f", barrelAngle) ..
		"T:" .. string.format("%.3f", barrelTarget)

	winchLabel.t                     = "Winch:" .. string.format("%.2f", headWinchPosition) .. "m"
	bitDepthLabel.t                  = "Bit  :" .. string.format("%.2f", bitDistance) .. "m"
	drillDepthLabel.t                = "Drill Depth:" .. string.format("%.2f", drillDepth) .. "m"
	wellDepthLabel.t                 = " Well Depth:" .. string.format("%.2f", wellDepth) .. "m"


	tickUI()

	outB(1,
		grabPipeButton.p,
		drillButton.p,
		adjustGripperLeftButton.p,
		adjustGripperRightButton.p,
		adjustJoinerLeftButton.p,
		adjustJoinerRightButton.p,
		barrelLeftButton.p,
		barrelRightButton.p,
		barrelIndexLeftButton.p,
		barrelIndexRightButton.p,
		mergeButton.p,
		bitWinchDownButton.p,
		bitWinchUpButton.p
	)
	outB(32, wellHeadLocked)
end

function onDraw()
	drawUI()
end
