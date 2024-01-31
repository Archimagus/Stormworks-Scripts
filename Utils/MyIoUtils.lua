---@section I
--- Alias for the input module.
I=input
---@endsection

---@section O
--- Alias for the output module.
O=output
---@endsection

---@section P
--- Alias for the property module.
P=property
---@endsection

---@section prB
--- Shortcut for getting boolean properties.
prB=P.getBool
---@endsection

---@section prN
--- Shortcut for getting number properties.
prN=P.getNumber
---@endsection

---@section prT
--- Shortcut for getting text properties.
prT=P.getText
---@endsection

---@section tU
--- Shortcut for unpacking tables (convert a table to a list of arguments).
tU = table.unpack
---@endsection

---@section tP
--- Shortcut for packing values into a table.
tP = table.pack
---@endsection

---@section tI
--- Shortcut for inserting items into a table.
tI = table.insert
---@endsection

---@section propN
--- Function to get multiple number properties at once.
--- @param ... string Variable number of property keys to get values for.
--- @return ... Multiple number properties.
function propN(...)local a={}for b,c in ipairs({...})do a[b]=P.getNumber(c)end;return tU(a) end
---@endsection

---@section propB
--- Function to get multiple boolean properties at once.
--- @param ... string Variable number of property keys to get values for.
--- @return ... Multiple boolean properties.
function propB(...)local a={}for b,c in ipairs({...})do a[b]=P.getBool(c)end;return tU(a) end
---@endsection

---@section getN
--- Function to get multiple input numbers at once.
--- @param ... number Variable number of input keys to get values for.
--- @return ... Multiple input numbers.
function getN(...)local a={}for b,c in ipairs({...})do a[b]=I.getNumber(c)end;return tU(a)end
---@endsection

---@section getB
--- Function to get multiple input booleans at once.
--- @param ... number Variable number of input keys to get values for.
--- @return ... Multiple input booleans.
function getB(...)local a={}for b,c in ipairs({...})do a[b]=I.getBool(c)end;return tU(a)end
---@endsection

---@section outN
--- Function to set multiple output numbers at once.
--- @param o number Starting index for the outputs.
--- @param ... number Values to set for consecutive output numbers.
function outN(o, ...) for i,v in ipairs({...}) do O.setNumber(o+i-1,v) end end
---@endsection

---@section outB
--- Function to set multiple output booleans at once.
--- @param o number Starting index for the outputs.
--- @param ... boolean Values to set for consecutive output booleans.
function outB(o, ...) for i,v in ipairs({...}) do O.setBool(o+i-1,v) end end
---@endsection
