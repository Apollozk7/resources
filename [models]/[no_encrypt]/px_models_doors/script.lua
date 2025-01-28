--[[

    author: @psychol.
    models: @jokerofficial
    script: @doors

]]

local doors={
    {"door1",1491},
    {"door2",1492},
    {"door3",1494},
    {"door4",1499},
    {"door5",1502},
}

for i,v in pairs(doors) do
    if(fileExists("files/"..v[1]..".txd"))then
        local txd=engineLoadTXD("files/"..v[1]..".txd", true)
        if(txd)then
            engineImportTXD(txd, v[2])
        end
    end

    if(fileExists("files/"..v[1]..".dff"))then
        local dff=engineLoadDFF("files/"..v[1]..".dff")
        if(dff)then
            engineReplaceModel(dff, v[2], true)
        end
    end

    if(fileExists("files/"..v[1]..".col"))then
        local col=engineLoadCOL("files/"..v[1]..".col")
        if(col)then
            engineReplaceCOL(col, v[2])
        end
    end
end