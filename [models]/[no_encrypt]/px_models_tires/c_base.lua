--[[

    author: psychol.

]]

local list={}

local models=exports.px_models_encoder

for i=1,5 do
    local id=engineRequestModel("object")
    if(id)then
        local name='opona'..i

        local txd=engineLoadTXD("models/"..name..".txd", true)
        engineImportTXD(txd, id)

        local dff=engineLoadDFF("models/"..name..".dff")
        engineReplaceModel(dff, id, true)

        models:addCustomModel(name,id)
        list[id]=id
    end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    for i,v in pairs(list) do
        models:removeCustomModel(v)
    end
end)