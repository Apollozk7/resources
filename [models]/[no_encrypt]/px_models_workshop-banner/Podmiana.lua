local s = engineLoadCOL ( "tabliczkamech.col" )
engineReplaceCOL ( s, 8324 )
local s = engineLoadTXD ( "tabliczkamech.txd" )
engineImportTXD ( s, 8324 )
local s = engineLoadDFF ( "tabliczkamech.dff" )
engineReplaceModel ( s, 8324 )

s = nil
setOcclusionsEnabled( false )