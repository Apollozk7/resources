
txd = engineLoadTXD("podloze.txd") 
dff = engineLoadDFF("podloze.dff") 

engineImportTXD(txd, 9062) 
engineReplaceModel(dff, 9062, true) 


txd = engineLoadTXD("podloze.txd") 
dff = engineLoadDFF("podloze1.dff") 

engineImportTXD(txd, 8420) 
engineReplaceModel(dff, 8420, true) 


setOcclusionsEnabled( false )   