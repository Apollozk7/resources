--[[

    author: @psychol.
    models: @jokerofficial
    script: @replace windows

]]

local models=exports.px_models_encoder

local windows={
    {"urzad",pos={{942.55,1733.2598,13.2}},doublesided=true},

    {"glasstaxi",pos={{2506.123,920.66992,13.236,0,0,180}}},
    {"glasstaxiplus",pos={{2497.2791,920.84399,11.56,0,0,180}}},
    {"glasstaxiplus2",pos={{2503.0701,921.69501,15.079,0,0,180}}},

    {"glasspolice",pos={{2341.47,2459.6499,17.6}}},
    {"glasspolice2",pos={{2322.9399,2471.2444,17.7}}},
    {"glasspolice3",pos={{2286.251,2423.9141,11.898,0,0,180}},dim=997,doublesided=true},
    {"glasspolice4",pos={{2251.248,2490.9146,11.9,0,0,90}},dim=997,doublesided=true},

    {"glassjobstation",pos={{262.30176,1431.8799,11.8}}},

    {"glassgielda",pos={{2792.82,1258.88,11.5,0,0,270}}},
}

for i,v in pairs(windows) do
    local id=engineRequestModel("object")
    if(id)then
        local txd=engineLoadTXD("files/"..v[1]..".txd", true)
        engineImportTXD(txd, id)

        local dff=engineLoadDFF("files/"..v[1]..".dff")
        engineReplaceModel(dff, id, true)

        if(fileExists("files/"..v[1]..".col"))then
            local col=engineLoadCOL("files/"..v[1]..".col")
            if(col)then
                engineReplaceCOL(col, id)
            end
        end

        models:addCustomModel(v[1],id)

        for i,k in pairs(v.pos) do
            local obj=createObject(id, unpack(k))
            if(v.dim)then
                setElementDimension(obj,v.dim)
            end
            if(v.doublesided)then
                setElementDoubleSided(obj,true)
            end
            if(v.col)then
                setElementCollisionsEnabled(obj,false)
            end
        end
    end
end

setOcclusionsEnabled(false)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for i,v in pairs(windows) do
        models:removeCustomModel(v[1])
    end
end)