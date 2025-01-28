--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.avatar=false

ui.draw["LOGOWANIE"]=function(a)
    dxDrawImage(sw/2-538/2/zoom, sh/2-168/zoom, 538/zoom, 464/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, a))

    dxDrawImage(sw/2-54/2/zoom, sh/2-168/zoom+29/zoom, 54/zoom, 54/zoom, (ui.avatar and isElement(ui.avatar)) and ui.avatar or assets.textures[7], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText('Witaj, '..getPlayerName(localPlayer), sw/2-538/2/zoom, sh/2-168/zoom+90/zoom, sw/2-538/2/zoom+538/zoom, 0, tocolor(245,245,245,a), 1, assets.fonts[2], 'center', 'top')
    dxDrawText('Wprowadź dane poniżej, aby się zalogować', sw/2-538/2/zoom, sh/2-168/zoom+121/zoom, sw/2-538/2/zoom+538/zoom, 0, tocolor(245,245,245,a), 1, assets.fonts[3], 'center', 'top')

    dxDrawImage(sw/2-210/zoom, sh/2+158/zoom, 19/zoom, 19/zoom, ui.save == 1 and assets.textures[9] or assets.textures[8], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText("Zapamiętaj dane", sw/2-210/zoom+32/zoom, sh/2+158/zoom, 19/zoom, sh/2+158/zoom+19/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")
    onClick(sw/2-210/zoom, sh/2+158/zoom, 19/zoom, 19/zoom, function()
        ui.save=ui.save == 1 and 0 or 1

        if(ui.save == 1)then
            local login=edits:dxGetEditText(ui.edits[1]) or ""
            local pass=edits:dxGetEditText(ui.edits[2]) or ""
            dx.savePlayerXML(login,pass)
        elseif(ui.save == 0)then
            dx.destroyPlayerXML()
        end
    end)

    local text=edits:dxGetEditText(ui.edits[1]) or ""
    if(ui.lastEdit ~= text)then
        ui.lastEdit=text
        ui.lastTick=getTickCount()
    end

    if(ui.lastEdit == text and (getTickCount()-ui.lastTick) > 5000 and ui.lastEdit ~= "")then
        triggerServerEvent("get.avatar", resourceRoot, text)
        ui.lastEdit=""
        ui.lastTick=getTickCount()
    end

    if(not ui.edits[1] and not ui.edits[2])then
        ui.edits[1]=edits:dxCreateEdit("Login", sw/2-417/2/zoom, sh/2+14/zoom, 417/zoom, 38/zoom, false, 11/zoom, a, false, false, ":px_auth/textures/login_edit.png")
        ui.edits[2]=edits:dxCreateEdit("Hasło", sw/2-417/2/zoom, sh/2+88/zoom, 417/zoom, 38/zoom, true, 11/zoom, a, false, false, ":px_auth/textures/password_edit.png")

        if(ui.login_save and #ui.login_save > 0)then
            edits:dxSetEditText(ui.edits[1], ui.login_save)
            edits:dxSetEditText(ui.edits[2], ui.password_save)
            ui.save=1
        end
    else
        for i,v in pairs(ui.edits) do
            edits:dxSetEditAlpha(v, a)
        end
    end

    if(not ui.btns[1])then
        ui.btns[1]=btns:createButton(sw/2-189/2/zoom, sh/2+215/zoom, 189/zoom, 43/zoom, "ZALOGUJ", a, 12, false, false, ":px_auth/textures/button_icon.png", {0,200,255})
    else
        for i,v in pairs(ui.btns) do
            btns:buttonSetAlpha(v,a)
        end

        onClick(sw/2-189/2/zoom, sh/2+215/zoom, 189/zoom, 43/zoom, function()
            if(SPAM.getSpam())then return end

            local login=edits:dxGetEditText(ui.edits[1]) or ""
            local pass=edits:dxGetEditText(ui.edits[2]) or ""
            if(string.len(login) >= 2 and string.len(pass) >= 2)then
                exports.px_noti:noti("Trwa uwierzytelnianie..", "info")
                triggerServerEvent("ui.loginPlayer", resourceRoot, login, pass, ui.save)
            else
                exports.px_noti:noti("Login i/lub hasło jest nieprawidłowe! (c)", "error")
            end
        end)
    end
end

-- avatar

addEvent("get.avatar", true)
addEventHandler("get.avatar", resourceRoot, function(tex)
    if(ui.avatar and isElement(ui.avatar))then
        destroyElement(ui.avatar)
        ui.avatar=false
    end

    if(tex)then
        local tex=dxCreateTexture(tex, "argb", false, "clamp")
        local shader=dxCreateShader(":px_avatars/shaders/hud_mask.fx")
        dxSetShaderValue(shader, "sPicTexture", tex)
        dxSetShaderValue(shader, "sMaskTexture", assets.textures[7])
        ui.avatar=shader
    end
end)