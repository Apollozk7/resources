--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local url="pixelmta/code_"

local pp=70

local awards={
    {1,1500},
    {5,10000},
    {10,20000},
    {30,50000},
    {70,100000}
}

function getUserInviteLink(uid)
    return url..uid
end

ui.rendering["Polecanie"]=function(a, mainA)
    local uid=getElementData(localPlayer, "user:uid")
    if(not uid)then return end

    a=a > mainA and mainA or a

    local texs=assets.textures["Polecanie"]
    if(not texs or (texs and #texs < 1))then return false end

    -- header
    dxDrawText("Polecanie", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Udostępnij link swoim znajomym i zdobywaj nagrody.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    -- info (desc)
    dxDrawText("Linku może użyć tylko i wyłącznie osoba,\nktóra na koncie nie ma przegrane więcej niż 1h,\na także posiada tylko jedno konto zarejestrowane\nna swój serial.", 426/zoom, 167/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "top")
    dxDrawText("Nagroda za udostępnienie zostanie przyznana\ndopiero wtedy, kiedy osoba zaproszona\nprzegra łącznie 10h.", 960/zoom, 167/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "top")

    dxDrawText("Gracz który użyje twojego kodu, otrzyma nagrodę w wysokości:", 960/zoom, 267/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "top")
    dxDrawText(pp.." PP", 960/zoom, 291/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[5], "left", "top")

    -- copy url
    local link=getUserInviteLink(uid)
    dxDrawText("Twój link:", sw-410/zoom, 48/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")
    dxDrawImage(sw-410/zoom, 74/zoom, 332/zoom, 49/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawImage(sw-410/zoom, 74/zoom, 49/zoom, 49/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawImage(sw-410/zoom+(49-16)/2/zoom, 74/zoom+(49-18)/2/zoom, 16/zoom, 18/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
    dxDrawRectangle(sw-410/zoom, 74/zoom+49/zoom-1, 332/zoom, 1, tocolor(80,80,80,a))
    dxDrawText(link,sw-410/zoom+49/zoom, 74/zoom, sw-410/zoom+332/zoom, 74/zoom+49/zoom, tocolor(200,200,200,a), 1, assets.fonts[2], "center", "center")
    onClick(sw-410/zoom, 74/zoom, 332/zoom, 49/zoom, function()
        setClipboard(link)
        noti:noti("Pomyślnie skopiowano link do schowka.", "success")
    end)

    -- link edit box
    if(not ui.edits["invites_1"] and not ui.buttons["invites_link"])then
        ui.edits["invites_1"]=editbox:dxCreateEdit("Wprowadź link", 426/zoom, 298/zoom, 200/zoom, 30/zoom, false, 11/zoom, a, false, false)
        ui.buttons["invites_link"]=buttons:createButton(426/zoom+220/zoom, 298/zoom, 147/zoom, 30/zoom, "ZATWIERDŹ", a, 9, false, false, ":px_dashboard/textures/2/button.png")
    else
        onClick(426/zoom+220/zoom, 298/zoom, 147/zoom, 30/zoom, function()
            local text=editbox:dxGetEditText(ui.edits["invites_1"]) or ""
            if(#text > 0)then
                if(SPAM.getSpam())then return end

                triggerServerEvent("dashboard.setInviteLink", resourceRoot, text, pp)
            else
                noti:noti("Najpierw wprowadź link.", "error")
            end
        end)
    end

    -- awards
    local inv=fromJSON(ui.info.user.invites) or {}
    local invites=#inv or 0

    for i,v in pairs(awards) do
        local sX=(233/zoom)*(i-1)
        dxDrawImage(426/zoom+sX, 391/zoom, 214/zoom, 249/zoom, texs[3], 0, 0, 0, tocolor(255, 255, 255, a))
        dxDrawText("Nagroda za zaproszenie", 426/zoom+sX, 391/zoom+17/zoom, 214/zoom+426/zoom+sX, 0, tocolor(200, 200, 200, a), 1, assets.fonts[8], "center", "top")
        dxDrawImage(426/zoom+sX+(214-67)/2/zoom, 391/zoom+55/zoom, 67/zoom, 67/zoom, texs[4], 0, 0, 0, tocolor(255, 255, 255, a))
        dxDrawText("Za "..v[1].." zrealizowanych linków", 426/zoom+sX, 391/zoom+136/zoom, 214/zoom+426/zoom+sX, 0, tocolor(150, 150, 150, a), 1, assets.fonts[3], "center", "top")
        dxDrawText("#4eb451$#b9babb "..convertNumber(v[2]), 426/zoom+sX, 391/zoom+160/zoom, 214/zoom+426/zoom+sX, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "center", "top", false, false, false, true)

        if(not ui.buttons["invites_"..i])then
            ui.buttons["invites_"..i]=buttons:createButton(426/zoom+sX+(214-147)/2/zoom, 391/zoom+249/zoom-53/zoom, 147/zoom, 38/zoom, "PRZYJMIJ", a, 9, false, false, ":px_dashboard/textures/2/button.png")
        else
            local aa=invites >= v[1] and 255 or 100
            buttons:buttonSetAlpha(ui.buttons["invites_"..i],a > aa and aa or a)

            onClick(426/zoom+sX+(214-147)/2/zoom, 391/zoom+249/zoom-53/zoom, 147/zoom, 38/zoom, function()
                if(invites >= v[1])then
                    if(SPAM.getSpam())then return end
                    
                    triggerServerEvent("dashboard.getInvitesWithdraw", resourceRoot, v[1], v[2])
                end
            end)
        end
    end

    -- users
    dxDrawText("Osoby zaproszone:", 426/zoom, sh-405/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    for i=1,7 do
        local v=inv[i]
        if(v)then
            local sY=(49/zoom)*(i-1)
            dxDrawImage(426/zoom, sh-372/zoom+sY, 392/zoom, 49/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

            local av=avatars:getPlayerAvatar(v.login)
            if(av)then
                dxDrawImage(426/zoom+17/zoom, sh-372/zoom+sY+(49-21)/2/zoom, 21/zoom, 21/zoom, av, 0, 0, 0, tocolor(255, 255, 255, a))
            end

            dxDrawText(v.login, 426/zoom+56/zoom, sh-372/zoom+sY, 392/zoom, sh-372/zoom+sY+49/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "left", "center")

            dxDrawRectangle(426/zoom, sh-372/zoom+49/zoom-1+sY, 392/zoom, 1, tocolor(80,80,80,a))
        end
    end
end