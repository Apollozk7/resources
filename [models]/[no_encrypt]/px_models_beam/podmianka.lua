
txd = engineLoadTXD ("beam.txd", 13009) 
engineImportTXD(txd, 13009)
dff = engineLoadDFF ("beam.dff", 13009)
engineReplaceModel(dff, 13009)
col = engineLoadCOL( "beam.col" )
engineReplaceCOL( col, 13009 )