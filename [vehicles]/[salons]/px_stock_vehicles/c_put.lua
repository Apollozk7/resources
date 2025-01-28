--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

local VEH = {}
VEH.btns = {}
VEH.edits = {}
VEH.checkbox=false

VEH.marker = createMarker(2808.6633,1313.0599,10.7500, "cylinder", 2, 168, 97, 97, 0)
setElementData(VEH.marker, "icon", ":px_stock_vehicles/textures/icon.png")
setElementData(VEH.marker, "text", {text="Giełda",desc="Wystawianie pojazdu"})

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 12},
        {":px_assets/fonts/Font-Medium.ttf", 10},
        {":px_assets/fonts/Font-Regular.ttf", 12},
    },

    textures={},
    textures_paths={
        "textures/window.png",
        "textures/icon_window.png",

        "textures/checkbox.png",
        "textures/checkbox_active.png",

        --

        "textures/zabieranie/window.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

VEH.onRender = function()
    if(not isPedInVehicle(localPlayer))then
        VEH.closeGui()
    end

    blur:dxDrawBlur(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, tocolor(255, 255, 255, 255))
    dxDrawImage(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 255), false)

    dxDrawText("Sprzedaż samochodu", sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+56/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "center", false)
    dxDrawImage(sw/2-557/2/zoom+385/zoom, sh/2-294/2/zoom+(56-19)/2/zoom+3/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, 255), false)

    dxDrawRectangle(sw/2-518/2/zoom, sh/2-294/2/zoom+56/zoom, 518/zoom, 1, tocolor(100, 100, 100))

    dxDrawText("#c2c2c2Wprowadź cenę, za którą chcesz wystawić swój\nsamochód marki #7cd8fd"..getVehicleName(getPedOccupiedVehicle(localPlayer)), sw/2-557/2/zoom, sh/2-294/2/zoom+73/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+56/zoom, tocolor(255, 255, 255, 255), 1, assets.fonts[2], "center", "top", false, false, false, true)

    dxDrawImage(sw/2-dxGetTextWidth("Wystaw offline (500$)", 1, assets.fonts[3])/2-30/zoom-10/zoom, sh/2+40/zoom-10/zoom, 40/zoom, 40/zoom, VEH.checkbox and assets.textures[4] or assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, 255), false)
    onClick(sw/2-dxGetTextWidth("Wystaw offline (500$)", 1, assets.fonts[3])/2-30/zoom-10/zoom, sh/2+40/zoom-10/zoom, 40/zoom, 40/zoom, function()
        VEH.checkbox=not VEH.checkbox
    end)
    dxDrawText("Wystaw offline (500$)", sw/2-dxGetTextWidth("Wystaw offline (500$)", 1, assets.fonts[3])/2, sh/2+40/zoom, 20/zoom, 20/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "left", "top", false, false, false, false, false)

    onClick(sw/2+20/zoom, sh/2+85/zoom, 148/zoom, 39/zoom, function()
        VEH.closeGui()
        setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
    end)

    onClick(sw/2-148/zoom-20/zoom, sh/2+85/zoom, 148/zoom, 39/zoom, function()
        noti = exports.px_noti

        local cost = editbox:dxGetEditText(VEH.edits[1])
        if(#cost >= 3 and #cost < 10 and tonumber(cost))then
            cost = tonumber(cost)
            cost = math.floor(cost)
            if(cost < 100 or cost > 10000000)then
                noti:noti("Wprowadziłeś błędną wartość.", "error")
                return
            end

            local v = getPedOccupiedVehicle(localPlayer)
            if(getElementHealth(v) < 1000)then
                noti:noti("Na giełdzie można wystawiać tylko naprawione pojazdy.", "error")
                return
            end

            local owner = getElementData(v, "vehicle:owner")
            local uid = getElementData(localPlayer, "user:uid")
            if(owner and uid and owner == uid)then
                VEH.closeGui()

                setElementFrozen(v, false)

                if(getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction"))then
                    noti:noti("Najpierw zakończ pracę.", "error")
                else
                    if(SPAM.getSpam())then return end

                    if(VEH.checkbox)then
                        if(getPlayerMoney(localPlayer) < 500)then
                            return
                        end
                    end

                    triggerServerEvent("set.vehicle", resourceRoot, v, cost, VEH.checkbox)
                end
            else
                noti:noti("Pojazd który chcesz wystawić nie należy do Ciebie.", "error")
            end
        else
            noti:noti("Wprowadzona wartość jest nieprawidłowa.", "error")
        end
    end)
end

VEH.openGui = function()
    VEH.checkbox=false

    editbox = exports.px_editbox
    buttons = exports.px_buttons
    noti = exports.px_noti
    blur=exports.blur

    addEventHandler("onClientRender", root, VEH.onRender)

    VEH.btns[1] = buttons:createButton(sw/2-148/zoom-20/zoom, sh/2+85/zoom, 148/zoom, 39/zoom, "SPRZEDAJ", 255, 10, false, false, ":px_stock_vehicles/textures/button.png")
    VEH.btns[2] = buttons:createButton(sw/2+20/zoom, sh/2+85/zoom, 148/zoom, 39/zoom, "ANULUJ", 255, 10, false, false, ":px_stock_vehicles/textures/close.png", {132,39,39})
    VEH.edits[1] = editbox:dxCreateEdit("Wpisz cene za samochód", sw/2-350/2/zoom, sh/2-10/zoom, 350/zoom, 25/zoom, false, 10/zoom, 255, true, false, ":px_stock_vehicles/textures/edit.png")

    showCursor(true)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    assets.create()
end

VEH.closeGui = function()
    editbox:dxDestroyEdit(VEH.edits[1])
    buttons:destroyButton(VEH.btns[1])
    buttons:destroyButton(VEH.btns[2])

    removeEventHandler("onClientRender", root, VEH.onRender)

    showCursor(false)

    setElementData(localPlayer, "user:gui_showed", false, false)

    assets.destroy()
end

addEventHandler("onClientMarkerHit", VEH.marker, function(hit, dim)
    if(hit ~= localPlayer or not dim or not isPedInVehicle(hit))then return end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    local vehicle = getPedOccupiedVehicle(hit)
    if(not getElementData(vehicle, "vehicle:id") or getVehicleController(vehicle) ~= hit)then return end

    VEH.openGui()
    setElementFrozen(vehicle, true)
end)

-- take vehicle

VEH.onTake = function()
    local v = getPedOccupiedVehicle(localPlayer)
    if(not v)then
        removeEventHandler("onClientRender", root, VEH.onTake)

        showCursor(false)

        buttons = exports.px_buttons

        buttons:destroyButton(VEH.btns[1])
        buttons:destroyButton(VEH.btns[2])

        setElementData(localPlayer, "user:gui_showed", false, false)
    end

    blur:dxDrawBlur(sw/2-557/2/zoom, sh/2-195/2/zoom, 557/zoom, 195/zoom, tocolor(255, 255, 255, 255))
    dxDrawImage(sw/2-557/2/zoom, sh/2-195/2/zoom, 557/zoom, 195/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, 255), false)

    dxDrawText("Giełda pojazdów", sw/2-557/2/zoom, sh/2-195/2/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-195/2/zoom+56/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "center", false)
    dxDrawImage(sw/2-557/2/zoom+385/zoom, sh/2-195/2/zoom+(56-19)/2/zoom+3/zoom, 19/zoom, 19/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, 255), false)

    dxDrawRectangle(sw/2-518/2/zoom, sh/2-195/2/zoom+56/zoom, 518/zoom, 1, tocolor(100, 100, 100))

    dxDrawText("Czy na pewno chcesz zabrać pojazd z giełdy?", sw/2-557/2/zoom, sh/2-195/2/zoom+87/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-195/2/zoom+56/zoom, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "center", "top", false, false, false, true)

    onClick(sw/2+20/zoom, sh/2+40/zoom, 148/zoom, 39/zoom, function()
        removeEventHandler("onClientRender", root, VEH.onTake)

        showCursor(false)

        buttons = exports.px_buttons

        buttons:destroyButton(VEH.btns[1])
        buttons:destroyButton(VEH.btns[2])

        setPedControlState(localPlayer, "enter_exit", true)
        setTimer(function()
            setPedControlState(localPlayer, "enter_exit", false)
        end, 50, 1)

        setElementData(localPlayer, "user:gui_showed", false, false)

        assets.destroy()
    end)

    onClick(sw/2-148/zoom-20/zoom, sh/2+40/zoom, 148/zoom, 39/zoom, function()
        if(SPAM.getSpam())then return end

        removeEventHandler("onClientRender", root, VEH.onTake)

        showCursor(false)

        buttons = exports.px_buttons
        noti = exports.px_noti

        buttons:destroyButton(VEH.btns[1])
        buttons:destroyButton(VEH.btns[2])

        noti:noti("Pomyślnie zabrano pojazd z giełdy.", "success")

        triggerServerEvent("get.vehicle", resourceRoot, v)

        setElementData(localPlayer, "user:gui_showed", false, false)

        assets.destroy()
    end)
end

addEventHandler("onClientVehicleEnter", root, function(player, seat)
    if(player ~= localPlayer)then return end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    local owner = getElementData(source, "vehicle:owner")
    local uid=getElementData(player, "user:uid")
    if(getElementData(source, "vehStock:puted") and uid and owner and uid==owner)then
        addEventHandler("onClientRender", root, VEH.onTake)

        showCursor(true)

        VEH.btns[1] = buttons:createButton(sw/2-148/zoom-20/zoom, sh/2+40/zoom, 148/zoom, 39/zoom, "ZABIERZ", 255, 10, false, false, ":px_stock_vehicles/textures/zabieranie/success.png")
        VEH.btns[2] = buttons:createButton(sw/2+20/zoom, sh/2+40/zoom, 148/zoom, 39/zoom, "ANULUJ", 255, 10, false, false, ":px_stock_vehicles/textures/close.png", {132,39,39})

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        assets.create()
    end
end)