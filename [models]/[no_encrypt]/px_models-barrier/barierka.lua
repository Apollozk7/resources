local s = engineLoadCOL ( "barierka.col" )
engineReplaceCOL ( s, 1228 )
local s = engineLoadTXD ( "barierka.txd" )
engineImportTXD ( s, 1228 )
local s = engineLoadDFF ( "barierka.dff" )
engineReplaceModel ( s, 1228, true )


setOcclusionsEnabled( false )
