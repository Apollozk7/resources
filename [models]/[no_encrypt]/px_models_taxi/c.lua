
modele = {
	{txd="modele/taxi.txd", dff="modele/taxi.dff", col="modele/taxi.col", model=1920},
	{txd="modele/taxi.txd", dff="modele/znak_taxi.dff", col="modele/znak_taxi.col", model=1921},
}

function podmianka()
	for k,v in ipairs(modele) do
		if v.col then
			local col = engineLoadCOL(v.col, v.model)
			engineReplaceCOL(col, v.model)
		end
		if v.dff then
			local dff = engineLoadDFF(v.dff, v.model)
			engineReplaceModel(dff, v.model)
		end
		if v.txd then
			local txd = engineLoadTXD(v.txd, v.model)
			engineImportTXD(txd, v.model)
		end
	end
end

podmianka()