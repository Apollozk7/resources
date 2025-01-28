--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.checkTrigger=true

ui.draw["REJESTRACJA"]=function(a)
    if(not ui.edits[1] and not ui.edits[2] and not ui.edits[3])then
        ui.edits[1]=edits:dxCreateEdit("Login", sw/2-417/2/zoom, sh/2-8/zoom, 417/zoom, 38/zoom, false, 11/zoom, a, false, false, ":px_auth/textures/login_edit.png")
        ui.edits[2]=edits:dxCreateEdit("Hasło", sw/2-417/2/zoom, sh/2+48/zoom, 417/zoom, 38/zoom, true, 11/zoom, a, false, false, ":px_auth/textures/password_edit.png")
        ui.edits[3]=edits:dxCreateEdit("E-mail", sw/2-417/2/zoom, sh/2+102/zoom, 417/zoom, 38/zoom, false, 11/zoom, a, false, false, ":px_auth/textures/mail_edit.png")
    else
        for i,v in pairs(ui.edits) do
            edits:dxSetEditAlpha(v, a)
        end
    end

    dxDrawImage(sw/2-538/2/zoom, sh/2-168/zoom, 538/zoom, 464/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, a))

    dxDrawImage(sw/2-54/2/zoom, sh/2-168/zoom+29/zoom, 54/zoom, 54/zoom, assets.textures[7], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText('Witaj, nieznajomy', sw/2-538/2/zoom, sh/2-168/zoom+90/zoom, sw/2-538/2/zoom+538/zoom, 0, tocolor(245,245,245,a), 1, assets.fonts[2], 'center', 'top')
    dxDrawText('Wprowadź dane poniżej, aby stworzyć konto', sw/2-538/2/zoom, sh/2-168/zoom+121/zoom, sw/2-538/2/zoom+538/zoom, 0, tocolor(245,245,245,a), 1, assets.fonts[3], 'center', 'top')

    dxDrawImage(sw/2-210/zoom, sh/2+158/zoom, 19/zoom, 19/zoom, ui.rules == 1 and assets.textures[9] or assets.textures[8], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText("Akceptuje regulamin", sw/2-210/zoom+32/zoom, sh/2+158/zoom, 19/zoom, sh/2+158/zoom+19/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[3], "left", "center")
    onClick(sw/2-210/zoom, sh/2+158/zoom, 19/zoom, 19/zoom, function()
      ui.rules=ui.rules == 1 and 0 or 1
    end)

    if(not ui.btns[1])then
        ui.btns[1]=btns:createButton(sw/2-189/2/zoom, sh/2+215/zoom, 189/zoom, 43/zoom, "ZAREJESTRUJ", a, 12, false, false, ":px_auth/textures/button_icon.png", {0,200,255})
    else
        for i,v in pairs(ui.btns) do
            btns:buttonSetAlpha(v,a)
        end

        onClick(sw/2-189/2/zoom, sh/2+215/zoom, 189/zoom, 43/zoom, function()
            if(not ui.checkTrigger)then
              exports.px_noti:noti("Zaczekaj chwilę.", "error")
              return
            end

            local login=edits:dxGetEditText(ui.edits[1]) or ""
            local pass=edits:dxGetEditText(ui.edits[2]) or ""
            local mail=edits:dxGetEditText(ui.edits[3]) or ""
            if(#login < 4)then
              exports.px_noti:noti("Login powinien posiadać przynajmniej 4 znaki.", "error")
            elseif(#pass < 7)then
              exports.px_noti:noti("Hasło powinno posiadać przynajmniej 7 znaków.", "error")
            elseif(#mail < 5)then
              exports.px_noti:noti("Adres e-mail powinien posiadać przynajmniej 5 znaków.", "error")
            elseif(#login > 15)then
              exports.px_noti:noti("Login powinien posiadać mniej niż 15 znaki.", "error")
            elseif(#pass > 50)then
              exports.px_noti:noti("Hasło powinno posiadać mniej niż 50 znaki.", "error")
            elseif(#mail > 100)then
              exports.px_noti:noti("Adres e-mail powinnien posiadać mniej niż 100 znaków.", "error")
            elseif(not isValidMail(mail))then
              exports.px_noti:noti("Adres e-mail jest nieprawidłowy.", "error")
            elseif(ui.rules ~= 1)then
              exports.px_noti:noti("Aby zagrać na serwerze musisz zaakceptować regulamin.", "error")
            else
              if(SPAM.getSpam())then return end

              triggerServerEvent("ui.registerPlayer", resourceRoot, login, pass, mail)

              ui.checkTrigger=false
            end
        end)
    end
end

addEvent("ui.checkTrigger", true)
addEventHandler("ui.checkTrigger", resourceRoot, function()
  ui.checkTrigger=true
end)