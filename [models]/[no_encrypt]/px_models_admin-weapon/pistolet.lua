function pistolet()

txd = engineLoadTXD ("pistolet.txd", 372) 
engineImportTXD(txd, 372)
dff = engineLoadDFF ("pistolet.dff", 372)
engineReplaceModel(dff, 372)

end

addEventHandler("onClientResourceStart", resourceRoot, pistolet )
