local s = engineLoadCOL ( "toolchestX.col" )
engineReplaceCOL ( s, 3963 )
local s = engineLoadTXD ( "toolchestX.txd" )
engineImportTXD ( s, 3963 )
local s = engineLoadDFF ( "toolchestX.dff" )
engineReplaceModel ( s, 3963 )

s = nil
setOcclusionsEnabled( false )