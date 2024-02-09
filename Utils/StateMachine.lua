require("LifeBoatAPI.Utils.LBCopy")

MyUtils = MyUtils or {}

MyUtils.StateMachine = {
	new = function(self, stateName, initialState)
		local obj = {}
		obj[stateName] = initialState
		obj.currentState = initialState
		obj.ticks = 0
		return LifeBoatAPI.lb_copy(self,
			obj
		)
	end,

	addState = function(self, stateName, stateFunction)
		self[stateName] = stateFunction
	end,

	onTick = function(self)
		local nextState = self[self.currentState](self)
		self.ticks = self.ticks + 1
		if nextState then
			self.currentState = nextState
			self.ticks = 0
		end
	end,
}
