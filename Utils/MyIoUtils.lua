
---@section I
I=input
---@endsection
---@section O
O=output
---@endsection
---@section P
P=property
---@endsection
---@section prB
prB=P.getBool
---@endsection
---@section prN
prN=P.getNumber
---@endsection
---@section prT
prT=P.getText
---@endsection

---@section tU
tU = table.unpack
---@endsection
---@section tP
tP = table.pack
---@endsection
---@section tI
tI = table.insert
---@endsection


---@section propN
function propN(...)local a={}for b,c in ipairs({...})do a[b]=P.getNumber(c)end;return tU(a) end
---@endsection
---@section propB
function propB(...)local a={}for b,c in ipairs({...})do a[b]=P.getBool(c)end;return tU(a) end
---@endsection
---@section getN
function getN(...)local a={}for b,c in ipairs({...})do a[b]=I.getNumber(c)end;return tU(a)end
---@endsection
---@section getB
function getB(...)local a={}for b,c in ipairs({...})do a[b]=I.getBool(c)end;return tU(a)end
---@endsection
---@section outN
function outN(o, ...) for i,v in ipairs({...}) do O.setNumber(o+i-1,v) end end
---@endsection
---@section outB
function outB(o, ...) for i,v in ipairs({...}) do O.setBool(o+i-1,v) end end
---@endsection