require("LifeBoatAPI.Utils.LBCopy")

ArchStateMachine = {
	new = function(self, initialState)
		return LifeBoatAPI.lb_copy(self, {
			currentState = initialState,
			ticks = 0,
		})
	end,

	onTick = function(self)
		self.ticks = self.ticks + 1
		local nextState = self.currentState(self)
		if nextState ~= nil then
			self.currentState = nextState
			self.ticks = 0
		end
	end,
}
