local txd = engineLoadTXD("journey.txd") 
engineImportTXD(txd, 508) 
local dff = engineLoadDFF("journey.dff", 508) 
engineReplaceModel(dff, 508)