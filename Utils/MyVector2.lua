---@section MYVECTOR2BOILERPLATE
--- Author: Archimagus
--- Utilities for vector math.
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search 'Stormworks Lua with LifeboatAPI' extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
---@endsection


---@diagnostic disable: duplicate-doc-field
---@section Vector2 1 _Vector2_
---@class Vector2
---@field x number
---@field y number
Vector2 = {}

---@param x? number
---@param y? number
function Vector2:new(x, y)
  local v = { x = x or 0, y = y or 0 }
  self.__index = self
  return setmetatable(v, Vector2)
end

---@section length
function Vector2:length()
  return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

---@endsection

---@section normalize
function Vector2:normalize()
  local length = self:length()
  self.x = self.x / length
  self.y = self.y / length
end

---@endsection

---@section add
function Vector2:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
end

---@endsection

---@section subtract
function Vector2:subtract(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
end

---@endsection

---@section multiply
function Vector2:multiply(scalar)
  self.x = self.x * scalar
  self.y = self.y * scalar
end

---@endsection

---@section divide
function Vector2:divide(scalar)
  self.x = self.x / scalar
  self.y = self.y / scalar
end

---@endsection

---@section distance
function Vector2:distance(other)
  local dx = self.x - other.x
  local dy = self.y - other.y
  return math.sqrt(dx ^ 2 + dy ^ 2)
end

---@endsection

---@section angle
---@param other?  Vector2
function Vector2:angle(other)
  if not other then return 0 end
  return math.atan(other.y - self.y, other.x - self.x)
end

---@endsection

---@section rotate
function Vector2:rotate(angle)
  local x = self.x
  local y = self.y
  self.x = x * math.cos(angle) - y * math.sin(angle)
  self.y = x * math.sin(angle) + y * math.cos(angle)
end

---@endsection
---@endsection _Vector2_
