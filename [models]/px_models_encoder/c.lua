--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- skalowanie
sw,sh=guiGetScreenSize()
zoom=1

local baseX=1920
local maxZoom=2
if(baseX > sw)then
    zoom=math.min(baseX/sw,maxZoom)
end
--

local custom_models={}

local with_windows={
    ["components_workshop"]=true,
    [8839]=true,
    ['mech']=true,
}

local modelsTypes={
    ['lakiernik_skin']='ped',
    ['mechanik_skin']='ped',
    ['tuner_skin']='ped',
}

function loadModel(v, max)
    local id, fileName, txdLength, dffLength, colLength, txd_iv, dff_iv, col_iv = unpack(v)
    local name

    -- load file    
    if(not fileExists(fileName))then 
        outputDebugString('[px_models_encoder] Model '..id..' have a problem. #1')
        return 
    end

    local file=fileOpen(fileName)
    if(not file)then 
        outputDebugString('[px_models_encoder] Model '..id..' have a problem. #2')
        return 
    end

    if(not tonumber(id))then 
        if(validVehicleModels[id])then
            id=validVehicleModels[id]
        else
            name=id

            id=engineRequestModel(modelsTypes[name] or "object")
            custom_models[name]=id
        end
    end

    -- start txd
    if(txdLength > 0)then
        local txdData = fileRead(file, txdLength)
        local txdIV = base64Decode(txd_iv)
        
        if(dffLength > 0)then
            fileSetPos(file, txdLength)
            local dffData = fileRead(file, dffLength)
            local dffIV = base64Decode(dff_iv)

            decodeString("aes128", txdData, { key = secret_key, iv = txdIV }, function(txdBuffer)
                local txd = engineLoadTXD(txdBuffer)
                if txd then
                    engineImportTXD(txd, id)
                end

                decodeString("aes128", dffData, { key = secret_key, iv = dffIV }, function(dffBuffer)
                    local dff = engineLoadDFF(dffBuffer)
                    if dff then
                        if(with_windows[name] or with_windows[id])then
                            engineReplaceModel(dff, id, true)
                        else
                            engineReplaceModel(dff, id)
                        end
                    end

                    if(colLength > 0)then
                        fileSetPos(file, txdLength+dffLength)
                        local colData = fileRead(file, colLength)
                        local colIV = base64Decode(col_iv)
            
                        decodeString("aes128", colData, { key = secret_key, iv = colIV }, function(colBuffer)
                            local col=engineLoadCOL(colBuffer)
                            if col then
                                engineReplaceCOL(col, id)
                            end
                            fileClose(file)
                        end)
                    else
                        fileClose(file)
                    end
                end)
            end)
        else
            decodeString("aes128", txdData, { key = secret_key, iv = txdIV }, function(txdBuffer)
                local txd = engineLoadTXD(txdBuffer)
                if txd then
                    engineImportTXD(txd, id)
                end

                fileSetPos(file, txdLength+dffLength)
                local colData = fileRead(file, colLength)
                local colIV = base64Decode(col_iv)

                if(colLength > 0)then
                    decodeString("aes128", colData, { key = secret_key, iv = colIV }, function(colBuffer)
                        local col=engineLoadCOL(colBuffer)
                        if col then
                            engineReplaceCOL(col, id)
                        end
                        fileClose(file)
                    end)
                else
                    fileClose(file)
                end
            end)
        end
    end

    -- start dff if txd is empty
    if(dffLength > 0 and txdLength < 1)then
        fileSetPos(file, txdLength)
        local dffData = fileRead(file, dffLength)
        local dffIV = base64Decode(dff_iv)

        fileSetPos(file, txdLength+dffLength)
        local colData = fileRead(file, colLength)
        local colIV = base64Decode(col_iv)

        decodeString("aes128", dffData, { key = secret_key, iv = dffIV }, function(dffBuffer)
            local dff = engineLoadDFF(dffBuffer)
            if dff then
                if(with_windows[name] or with_windows[id])then
                    engineReplaceModel(dff, id, true)
                else
                    engineReplaceModel(dff, id)
                end
            end

            if(colLength > 0)then
                decodeString("aes128", colData, { key = secret_key, iv = colIV }, function(colBuffer)
                    local col=engineLoadCOL(colBuffer)
                    if col then
                        engineReplaceCOL(col, id)
                    end
                    fileClose(file)
                end)
            else
                fileClose(file)
            end
        end)
    end


    if(dffLength < 1 and txdLength < 1 and colLength > 0)then
        fileSetPos(file, txdLength+dffLength)
        local colData = fileRead(file, colLength)
        local colIV = base64Decode(col_iv)

        decodeString("aes128", colData, { key = secret_key, iv = colIV }, function(colBuffer)
            local col=engineLoadCOL(colBuffer)
            if col then
                engineReplaceCOL(col, id)
            end
            fileClose(file)
        end)
    end
end

function loadFiles()
    local file=loadFile("assets.json")
    if(file)then
        local tbl=fromJSON(file) or {}
        for x,v in pairs(tbl) do
            loadModel(v,#tbl)
        end

        triggerEvent('px_models_encoder:started', root)
    end
end
setTimer(loadFiles, 1000, 1)

-- exports

function getCustomModels()
    return custom_models
end

function getCustomModelID(name)
    return custom_models[name]
end

function addCustomModel(name,id)
    custom_models[name]=id
end

function removeCustomModel(name)
    custom_models[name]=nil
end

-- events

addEventHandler("onClientResourceStop", resourceRoot, function()
    for i,v in pairs(custom_models) do
        if(tonumber(v))then
            engineFreeModel(v)
        end
    end
end)