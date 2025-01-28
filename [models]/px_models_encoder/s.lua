--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local modelsResourceName="px_models_files"

function addFileToAssets(id, fileName, dffLength, txdLength, colLength, assets, txd_iv, dff_iv, col_iv)
    local file=loadFile(assets)
    if(file)then
        local tbl=fromJSON(file) or {}
        local exist=false
        for i,v in pairs(tbl) do
            if(v[1] == id)then
                tbl[i]={id, fileName, dffLength, txdLength, colLength, txd_iv, dff_iv, col_iv}
                exist=true
                break
            end
        end

        if(not exist)then
            tbl[#tbl+1]={id, fileName, dffLength, txdLength, colLength, txd_iv, dff_iv, col_iv}
        end

        saveFile(assets, toJSON(tbl))
    end
end

function addFileToMeta(path, meta)
    local xml = xmlLoadFile(meta)
    if(xml)then
        local exists=false
        for index,node in pairs ( xmlNodeGetChildren ( xml ) ) do
            if xmlNodeGetName ( node ) == "file" then
                if(xmlNodeGetAttribute(node,"src") == path)then
                    exists=true
                end
            end
        end

        if(not exists)then
            local child = xmlCreateChild(xml, "file")
            xmlNodeSetAttribute(child, "src", path)
            xmlSaveFile(xml)
        end

        xmlUnloadFile(xml)
        
    end
end

function encryptModel(name, path)
    path=path or ""

    outputDebugString("(px_models_encoder) Trwa szukanie i ładowanie "..name)

    local txd = loadFile(":"..modelsResourceName.."/"..name..".txd")
    local dff = loadFile(":"..modelsResourceName.."/"..name..".dff")
    local col = loadFile(":"..modelsResourceName.."/"..name..".col")

    local txd_encoded, txd_iv = "", ""
    if(txd)then
        txd_encoded, txd_iv = encodeString("aes128", txd, { key = secret_key })
    end

    local dff_encoded, dff_iv = "", ""
    if(dff)then
        dff_encoded, dff_iv = encodeString("aes128", dff, { key = secret_key })
    end

    local col_encoded, col_iv = "", ""
    if(col)then
        col_encoded, col_iv = encodeString("aes128", col, { key = secret_key })
    end
    
    local saved=saveFile(path.."models/"..md5(name)..".px", txd_encoded..dff_encoded..col_encoded)
    if(saved)then
        outputDebugString("(px_models_encoder) Pomyślnie załadowano i zakodowano: "..name)
        addFileToMeta("models/"..md5(name)..".px", path.."meta.xml")
        addFileToAssets(tonumber(name) or name, "models/"..md5(name)..".px", #txd_encoded, #dff_encoded, #col_encoded, path.."assets.json", base64Encode(txd_iv), base64Encode(dff_iv), base64Encode(col_iv))
    end
end

function encryptModels()
    outputDebugString("(px_models_encoder) Trwa ładowanie modelów...")

    local resourceMeta=XML.load(":"..modelsResourceName.."/meta.xml")
    if(not resourceMeta)then
        outputDebugString("(px_models_encoder) Błąd w trakcie ładowania skryptu z modelami: "..modelsResourceName)
        return
    end

    local fileHandle = fileCreate("assets.json")
    if fileHandle then
        fileWrite(fileHandle, "")
        fileClose(fileHandle)
    end

    for i,child in pairs(resourceMeta.children) do
        if(child.name == "file")then
            local path = child:getAttribute("src")
            encryptModel(path)
        end
    end
    
    xmlUnloadFile(resourceMeta)
end

addCommandHandler("encrypt", function(player,_,name,path)
    if(isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) or isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Console")))then
        if(name)then
            if(path)then path=":px_models_send/" end
            encryptModel(name,path)
        else
            encryptModels()
        end
    end
end)

function searchInMeta(meta,path)
    local exists=false
    local xml = xmlLoadFile(meta)
    if(xml)then
        for index,node in pairs ( xmlNodeGetChildren ( xml ) ) do
            if xmlNodeGetName ( node ) == "file" then
                if(xmlNodeGetAttribute(node,"src") == path)then
                    exists=true
                    break
                end
            end
        end
    end
    xmlUnloadFile(xml)
    return exists
end