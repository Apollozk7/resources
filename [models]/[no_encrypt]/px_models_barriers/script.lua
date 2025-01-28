--[[

    author: @psychol.
    models: @savenq
    script: @replace windows

]]

local models=exports.px_models_encoder

local elements={
    "znak_dui",
    "znak1",
    "znak2",
    "znak3"
}

for i,v in pairs(elements) do
    local id=engineRequestModel("object")
    if(id)then
        local txd=engineLoadTXD("files/tekstury.txd", true)
        engineImportTXD(txd, id)

        local dff=engineLoadDFF("files/"..v..".dff")
        engineReplaceModel(dff, id, true)

        local col=engineLoadCOL("files/znaki.col")
        engineReplaceCOL(col, id)

        models:addCustomModel(v,id)
    end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    for i,v in pairs(elements) do
        models:removeCustomModel(v)
    end
end)