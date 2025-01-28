--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local settings_lists_1={
    [1]={
        ["voice_chat"]={name="Czat głosowy",id=2},
        ["vehicles_sounds"]={name="Dźwięki pojazdów",id=3},
        ["fps_counter"]={name="Licznik FPS",id=4},
        ["showed_hud"]={name="Ukryj HUD",id=5},
        ["premium_notis"]={name="Ukryj ogłoszenia",id=6},
        ["private_messages"]={name="Blokada prywatnych wiadomości",id=7},
        ["friends_invites"]={name="Blokada zaproszeń do znajomych",id=8},
        ["3dmusic"]={name="Wyłącz muzyke 3D",id=9},
    },

    [2]={
        ["PREMIUM_chat_off"]={name="Wyłącz czat PREMIUM",id=10},
        ["GOLD_chat_off"]={name="Wyłącz czat GOLD",id=11},

        ["nametag_distance"]={name="Większa widzialność nicków (-FPS)",id=12},
    },
}

local settings_lists_2={
    ["bloom"]={name="Bloom",id=14},
    ["detals_contrast"]={name="Ostrość detali",id=15},
    ["detals"]={name="Szczególność detali",id=16},
    ["blur"]={name="Rozmycie radialne",id=17},
    ["sky"]={name="Realistyczne niebo",id=18},
    ["distance"]={name="Wysoki dystans rysowania",id=19},
}

local menu={
    {name="Ustawienia rozgrywki", draw=function(texs,a)
        local pos={
            [1]=380/zoom,
            [2]=(380+700)/zoom
        }

        for key,t in pairs(settings_lists_1) do
            local k=0
            for i,v in pairs(t) do
                k=k+1

                local sY=(71/zoom)*(k-1)
                dxDrawText(v.name, pos[key]+45/zoom, 272/zoom+sY, pos[key]+243/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "center")

                local state=getSettingState(i)
                local aa=state and 100 or 255
                aa=aa > a and a or aa
                
                dxDrawImage(pos[key]+100/zoom+243/zoom, 272/zoom+sY, 143/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, aa))
                dxDrawRectangle(pos[key]+100/zoom+243/zoom, 272/zoom+sY+49/zoom-1, 143/zoom, 1, not state and tocolor(137,51,51,aa) or tocolor(80, 80, 80, aa))
                dxDrawText("Nie", pos[key]+100/zoom+243/zoom, 272/zoom+sY, pos[key]+100/zoom+243/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[2], "center", "center")
                onClick(pos[key]+100/zoom+243/zoom, 272/zoom+sY, 143/zoom, 49/zoom, function()
                    setSettingState(i, nil)
                end)
                
                local aa=state and 255 or 100
                aa=aa > a and a or aa
                dxDrawImage(pos[key]+100/zoom+243/zoom+164/zoom, 272/zoom+sY, 143/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, aa))
                onClick(pos[key]+100/zoom+243/zoom+164/zoom, 272/zoom+sY, 143/zoom, 49/zoom, function()
                    setSettingState(i, true)
                end)
                dxDrawRectangle(pos[key]+100/zoom+243/zoom+164/zoom, 272/zoom+sY+49/zoom-1, 143/zoom, 1, state and tocolor(57,121,48,aa) or tocolor(80, 80, 80, aa))
                dxDrawText("Tak", pos[key]+100/zoom+243/zoom+164/zoom, 272/zoom+sY, pos[key]+100/zoom+243/zoom+164/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[2], "center", "center")
            end                
        end
    end},

    {name="Ustawienia graficzne", draw=function(texs,a)
        local k=0
        for i,v in pairs(settings_lists_2) do
            k=k+1

            local sY=(71/zoom)*(k-1)
            dxDrawText(v.name, 380/zoom+45/zoom, 272/zoom+sY, 380/zoom+243/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(150, 150, 150, a), 1, assets.fonts[2], "left", "center")

            local state=getSettingState(i)
            local aa=state and 100 or 255
            aa=aa > a and a or aa

            dxDrawImage(480/zoom+243/zoom, 272/zoom+sY, 143/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, aa))
            dxDrawRectangle(480/zoom+243/zoom, 272/zoom+sY+49/zoom-1, 143/zoom, 1, not state and tocolor(137,51,51,aa) or tocolor(80, 80, 80, aa))
            dxDrawText("Nie", 480/zoom+243/zoom, 272/zoom+sY, 480/zoom+243/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[2], "center", "center")
            onClick(480/zoom+243/zoom, 272/zoom+sY, 143/zoom, 49/zoom, function()
                setSettingState(i, nil)
            end)
            
            local aa=state and 255 or 100
            aa=aa > a and a or aa
            dxDrawImage(480/zoom+243/zoom+164/zoom, 272/zoom+sY, 143/zoom, 49/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, aa))
            onClick(480/zoom+243/zoom+164/zoom, 272/zoom+sY, 143/zoom, 49/zoom, function()
                setSettingState(i, true)
            end)
            dxDrawRectangle(480/zoom+243/zoom+164/zoom, 272/zoom+sY+49/zoom-1, 143/zoom, 1, state and tocolor(57,121,48,aa) or tocolor(80, 80, 80, aa))
            dxDrawText("Tak", 480/zoom+243/zoom+164/zoom, 272/zoom+sY, 480/zoom+243/zoom+164/zoom+143/zoom, 272/zoom+sY+49/zoom, tocolor(200, 200, 200, aa), 1, assets.fonts[2], "center", "center")
        end
    end},
}

local selected=1

ui.rendering["Ustawienia"], desc=function(a, mainA)
    local uid=getElementData(localPlayer, "user:uid")
    if(not uid)then return end

    a=a > mainA and mainA or a

    local texs=assets.textures["Ustawienia"]
    if(not texs or (texs and #texs < 1))then return false end

    -- header
    dxDrawText("Ustawienia", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Zarządzaj rozgrywką, ustawieniami graficznymi oraz zabezpiecz swoje konto.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")
        
    dxDrawRectangle(381/zoom+1, 140/zoom, 1494/zoom, 1, tocolor(80,80,80,a > 50 and 50 or a))
    dxDrawImage(381/zoom+1, 140/zoom+1, 1279/zoom, 70/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

    local sX=0
    for i,v in pairs(menu) do
        local w=dxGetTextWidth(v.name, 1, assets.fonts[2])

        dxDrawText(v.name, 380/zoom+45/zoom+sX, 140/zoom+1+22/zoom, 380/zoom+45/zoom+sX+w, 20/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[2], "center", "top")

        if(selected == i)then
            dxDrawRectangle(380/zoom+45/zoom+sX, 140/zoom+1+22/zoom+25/zoom, w, 1, tocolor(40,102,119,a))
        end

        onClick(380/zoom+45/zoom+sX, 140/zoom+1+22/zoom, w, 20/zoom, function()
            selected=i
        end)

        sX=sX+w+57/zoom
    end

    menu[selected].draw(texs,a)
end

-- useful

function getSettingState(name, element)
    local settingData=getElementData(element or localPlayer, "user:dash_settings")
    local settingBase=settings_lists_1[1][name] or settings_lists_1[2][name] or settings_lists_2[name]
    if(settingBase and settingData)then
        local settingID=settingBase.id
        local settingState=settingData[settingID]
        return tonumber(settingState) == 1
    end
    return false
end

function setSettingState(name, type)
    local settingData=getElementData(localPlayer, "user:dash_settings") or {}
    local settingBase=settings_lists_1[1][name] or settings_lists_1[2][name] or settings_lists_2[name]
    if(settingBase and settingData)then
        local settingID=settingBase.id
        settingData[settingID]=type and 1 or 0
        setElementData(localPlayer, "user:dash_settings", settingData)
    end
end

-- dystans rysowania

addEventHandler("onClientElementDataChange", root, function(data,last,new)
	if data == "user:dash_settings" then
		local state=getSettingState("distance")
        distance(state)

        local state=getSettingState("wood_pc")
        lowDistance(state)
	end
end)

local on = false
function distance(state)
	if state and not on then
        setFarClipDistance(10000)

		on = true
    elseif not state and on then
        resetFarClipDistance()

		on = false
	end
end

local on2 = false
function lowDistance(state)
	if state and not on2 then
        setFarClipDistance(200)

		on2 = true
    elseif not state and on2 then
        if(on)then
            setFarClipDistance(10000)
        else
            resetFarClipDistance()
        end

		on2 = false
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	local state=getSettingState("distance")
	distance(state)

	local state=getSettingState("wood_pc")
	lowDistance(state)
end)
