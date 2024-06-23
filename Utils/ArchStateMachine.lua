require("LifeBoatAPI.Utils.LBCopy")

---@type ArchStateFunction
---@alias ArchStateFunction fun(self: ArchStateMachine):ArchStateFunction|nil

---@class ArchStateMachine
---@field states table<string, function>
---@field currentStateId string
---@field currentStateFn function
---@field ticks number
---@field new function
---@field addState function
---@field onTick function
ArchStateMachine = {
	---Create a new state machine
	---@param self ArchStateMachine
	---@param initialStateId number
	---@param initialState ArchStateFunction
	---@return ArchStateMachine|T
	new = function(self, initialStateId, initialState)
		return LifeBoatAPI.lb_copy(self, {
			states = {
				[initialStateId] = initialState
			},
			currentStateId = initialStateId,
			currentStateFn = initialState,
			ticks = 0,
		})
	end,

	--- Add a state to the state machine
	---@param self any
	---@param stateId number
	---@param stateFn ArchStateFunction
	addState = function(self, stateId, stateFn)
		self.states[stateId] = stateFn
	end,

	---Tick the state machine, calls the current state function with self
	--- and updates the current state if necessary
	---@param self ArchStateMachine
	onTick = function(self)
		self.ticks = self.ticks + 1
		local nextState = self.currentStateFn(self)
		if nextState ~= nil then
			self.currentStateId = nextState
			self.currentStateFn = self.states[nextState]
			self.ticks = 0
		end
	end,
}
