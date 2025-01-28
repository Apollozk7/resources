
local dff = engineLoadDFF("PrzechoLV.dff") 
engineReplaceModel(dff,8472, true)
local col = engineLoadCOL("PrzechoLV.col")  
engineReplaceCOL(col,8472)