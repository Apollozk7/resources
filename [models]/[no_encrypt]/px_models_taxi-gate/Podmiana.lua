local s = engineLoadCOL ( "bramataxi.col" )
engineReplaceCOL ( s, 10149 )
local s = engineLoadTXD ( "bramataxi.txd" )
engineImportTXD ( s, 10149 )
local s = engineLoadDFF ( "bramataxi.dff" )
engineReplaceModel ( s, 10149, true )

setOcclusionsEnabled( false )

