
txd = engineLoadTXD("lawka.txd") 
dff = engineLoadDFF("lawka.dff") 

engineImportTXD(txd, 1368) 
engineReplaceModel(dff, 1368, true) 



setOcclusionsEnabled( false )   
