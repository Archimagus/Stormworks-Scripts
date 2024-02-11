require("LifeBoatAPI.Utils.LBCopy")

MyUtils = MyUtils or {}

MyUtils.StateMachine = {
	new = function(self, stateId, initialState)
		local obj = {
			states = {
				[stateId] = initialState
			}
		}
		obj.currentState = stateId
		obj.ticks = 0
		return LifeBoatAPI.lb_copy(self,
			obj
		)
	end,

	addState = function(self, stateId, stateFunction)
		self.states[stateId] = stateFunction
	end,

	onTick = function(self)
		self._stateFunc = self.states[self.currentState]
		local nextState = self._stateFunc(self)
		self.ticks = self.ticks + 1
		if nextState ~= nil then
			self.currentState = nextState
			self.ticks = 0
		end
	end,
}
