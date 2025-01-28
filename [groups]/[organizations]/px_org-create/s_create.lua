--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local G={}

G.points={
    {928.2780,1752.9100,8.8516},
}

G.defaultRanks={
    {name="Lider"},
    {name="V-Lider"},
    {name="Menadżer"},
    {name="Początkujący"},
}

for i,v in pairs(G.points) do
    marker=createMarker(v[1], v[2], v[3]-1, "cylinder", 1.1, 0, 255, 125)
    setElementData(marker, "icon", ":px_bank_acc_create/assets/textures/marker.png")
    setElementData(marker, "text", {text="Zakładanie organizacji",desc="Urząd miasta Las Venturas"})
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then        
        local org=getElementData(hit, "user:organization")
        if(org)then
            exports.px_noti:noti("Aby założyć organizacje, odejdź z tymczasowej.", hit, "error")
        else
            triggerClientEvent(hit, "open.interface", resourceRoot)
        end
    end
end)

addEvent("create.organization", true)
addEventHandler("create.organization", resourceRoot, function(name, tag, money)
    local uid=getElementData(client, "user:uid")
    if(uid and name and tag)then
        local q=exports.px_connect:query("select org,tag from groups_organizations where org=? or tag=? limit 1", name, tag)
        if(q and #q > 0)then
            exports.px_noti:noti("Podana nazwa/tag organizacji jest już zajęta.", client, "error")
            return
        end

        if(getPlayerMoney(client) >= money)then
            takePlayerMoney(client, money)

            local q,_,id=exports.px_connect:query("insert into groups_organizations (org,ranks,tag) values(?,?,?)", name, toJSON(G.defaultRanks), tag)
            exports.px_connect:query("insert into groups_organizations_players (uid,login,org,`rank`) values(?,?,?,?)", uid, getPlayerName(client), name, "Lider")

            exports.px_noti:noti("Pomyślnie stworzono organizację "..name.." ("..tag..") za kwotę "..money.."$.", client, "success")

            setElementData(client, "user:organization", name)
            setElementData(client, "user:organization_tag", tag)
            setElementData(client, "user:organization_rank", 'Lider')

            exports.px_organizations:setOrganizationTasks(name)
        end
    end
end)