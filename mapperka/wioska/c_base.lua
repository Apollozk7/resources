--[[

    author: psychol.

]]

local list={
    '16197',
    '16202',
    '16203',
    '16204',
    '16205',
    '16208',
    '16209',
    '16210',
    '16257',
    '16259',
    '16261',
}

for i,v in pairs(list) do
    local txd=engineLoadTXD("models/"..v..".txd", true)
    engineImportTXD(txd, tonumber(v))

    local dff=engineLoadDFF("models/"..v..".dff")
    engineReplaceModel(dff, tonumber(v), true)

    local col=engineLoadCOL("models/"..v..".col")
    if col then
        engineReplaceCOL(col, tonumber(v))
    end
end