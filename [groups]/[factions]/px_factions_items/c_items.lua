--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur
local noti=exports.px_noti
local preview=exports.object_preview

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/close.png",
        "textures/row.png",
        "textures/row_hover.png",
        
        -- sapd
        "textures/icon_1.png",
        "textures/icon_2.png",
        "textures/icon_3.png",
        "textures/icon_4.png",
        "textures/icon_5.png",
        "textures/icon_6.png",
        "textures/icon_7.png",
        "textures/icon_8.png",
        --

        -- sara
        "textures/bucket.png",
        "textures/lamp.png",
        "textures/kanister.png",
        "textures/fix.png",
        "textures/tire.png",
        "textures/icon_7.png",
        --
    },

    fonts={
        {"Medium", 15},
        {"SemiBold", 10},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

local ui={}

ui.table={}
for i=1,4 do
    local sY=(103/zoom)*(i-1)
    for i=1,5 do
        local sX=(103/zoom)*(i-1)
        ui.table[#ui.table+1]={sX=sX,sY=sY}
    end
end

-- draw

ui.infos={}
ui.items={
    ["SAPD"]={
        ["vehicle"]={
            desc="Wyposażenie frakcyjne",
            items={
                {name="Strzelba", gun=25, ammo=99999, access="Strzelby"}, 
                {name="Deagle", gun=24, ammo=99999, access="Broń krótka"}, 
                {name="M4", gun=31, ammo=99999, access="Broń długa"}, 
                {name="MP5", gun=29, ammo=99999, access="Broń długa"}, 
                {name="Paralizator", gun=23, ammo=99999, access="Broń krótka"}, 
                {name="Pałka", gun=3, ammo=1, access="Broń krótka"}, 
                {name="Suszarka", gun=32, ammo=1, access="Broń krótka"}, 
                {name="Kamizelka", armor=true}, 
            },
        },

        ["skins"]={
            desc="Przebieralnia frakcyjna",
            items={
                {id=265,skin=true},
                {id=266,skin=true},
                {id=267,skin=true},
                {id=280,skin=true},
                {id=281,skin=true},
                {id=282,skin=true},
                {id=283,skin=true},
                {id=284,skin=true},
                {id=285,skin=true},
            }
        }
    },

    ["SACC"]={
        ["skins"]={
            desc="Przebieralnia frakcyjna",
            items={
                {id=171,skin=true,role="Początkujący"},
                {id=295,skin=true,role="Pracownik"},
                {id=164,skin=true,role="Zaufany"},
                {id=296,skin=true,role="FAKETAXI"},
            }
        }
    },

    ["PSP"]={
        ["skins"]={
            desc="Przebieralnia frakcyjna",
            items={
                {id=279,skin=true},
                {id=274,skin=true},
                {id=276,skin=true},
                {id=277,skin=true},
                {id=278,skin=true,sound=true},
                {id=275,skin=true},
            }
        },

        ["vehicle"]={
            desc="Wyposażenie frakcyjne",
            items={
                {name="Wiadro z sorbentem", access="Wyposażenie",type="item",id=2713,pAttach={0, 0, 0, 0, 270, 90}},
                --{name="Deska", access="Wyposażenie",type="item",id="deska",pAttach={-0.5, 0, 0.2, 0, 0, 0},tex=true,stopAnim=true},
                {name="Torba", access="Wyposażenie",type="item",id="torbaz",pAttach={0, -0.2, 0, 0, 270, 90},tex=true,stopAnim=true},
                {name="Rozpieracz", access="Wyposażenie",type="item",id="rozpierak",pAttach={0, 0.1, 0, -30, 0, -30},tex=true},
                {name="Hooligan", access="Wyposażenie",type="item",id="hooligan",pAttach={0, 0.04, -0.02, 0, 0, 0},tex=true,stopAnim=true},
                {name="Piła", gun=9, ammo=1, access="Wyposażenie",tex=true}, 
                {name="AODO",id=278,skin=true, access="Wyposażenie",sound=true},
                {name="NOMEX",id=279,skin=true, access="Wyposażenie"},
            },
        },
    },

    ["SARA"]={
        ["vehicle"]={
            desc="Wyposażenie frakcyjne",
            items={
                {name="Wiadro z sorbentem", access="Wyposażenie",type="item",id=2713,pAttach={0, 0, 0, 0, 270, 90}},
                {name="Skrzynka do lamp", access="Wyposażenie",type="item",id=3963,pAttach={0, -0.1, -0.05, 0, 270, 0}},
                {name="Kanister 5L", access="Wyposażenie",type="item",id=1650,pAttach={0, 0, 0, 0, 270, 90}},
                {name="Zestaw naprawczy", access="Wyposażenie",type="item",id=3963,pAttach={0, -0.1, -0.05, 0, 270, 0}},
                {name="Opona", access="Wyposażenie",type="item",id="opona"},
                {name="Suszarka", gun=32, ammo=1, access="Wyposażenie", index=11}, 
            },
        },

        ["skins"]={
            desc="Przebieralnia frakcyjna",
            items={
                {id="sara_skin_1",skin=true,role="Początkujący"},
                {id="sara_skin_2",skin=true,role="Początkujący"},
                {id="sara_skin_3",skin=true,role="Początkujący"},
                {id="sara_skin_4",skin=true,role="Początkujący"},
                {id="sara_skin_5",skin=true,role="Początkujący"},
                {id="sara_skin_6",skin=true,role="Początkujący"},
                {id="sara_skin_7",skin=true,role="Początkujący"},
                {id="sara_skin_8",skin=true,role="Początkujący"},
            }
        }
    }
}

ui.lastUsed=0
ui.preview={}

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

ui.onRender=function()
    local items=ui.items[ui.infos[1]]
    local items2=false
    if(not items)then
        ui.destroy()
        return
    else
        items=items[ui.infos[2]]
        if(not items)then
            ui.destroy()
            return
        end
    end

    blur:dxDrawBlur(sw-532/zoom-23/zoom, sh/2-487/2/zoom, 532/zoom, 487/zoom)
    dxDrawImage(sw-532/zoom-23/zoom, sh/2-487/2/zoom, 532/zoom, 487/zoom, assets.textures[1])
    dxDrawText(items.desc, sw-532/zoom-23/zoom, sh/2-487/2/zoom, 532/zoom+sw-532/zoom-23/zoom, sh/2-487/2/zoom+55/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
    dxDrawRectangle(sw-532/zoom-23/zoom+(532-508)/2/zoom, sh/2-487/2/zoom+55/zoom, 508/zoom, 1, tocolor(81, 81, 81))
    dxDrawImage(sw-532/zoom-23/zoom+(532-508)/2/zoom+508/zoom-10/zoom, sh/2-487/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[2])

    for i,v in pairs(ui.table) do
        v.alpha=v.alpha or 255
        v.hoverAlpha=v.hoverAlpha or 0

        if(v.hoverAlpha and isMouseInPosition(sw-532/zoom-23/zoom+12/zoom+v.sX, sh/2-487/2/zoom+73/zoom+v.sY, 96/zoom, 96/zoom) and not v.animate and v.hoverAlpha < 255)then
            v.animate=true
            animate(0, 255, "Linear", 250, function(a)
                v.hoverAlpha=a
                v.alpha=255-a
            end, function()
                v.animate=false
            end)
        elseif(v.hoverAlpha and not isMouseInPosition(sw-532/zoom-23/zoom+12/zoom+v.sX, sh/2-487/2/zoom+73/zoom+v.sY, 96/zoom, 96/zoom) and not v.animate and v.hoverAlpha > 0)then
            v.animate=true
            animate(255, 0, "Linear", 250, function(a)
                v.hoverAlpha=a
                v.alpha=255-a
            end, function()
                v.animate=false
            end)
        end

        dxDrawImage(math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX), math.floor(sh/2-487/2/zoom+73/zoom+v.sY), 96/zoom, 96/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, v.alpha))
        dxDrawImage(math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX), math.floor(sh/2-487/2/zoom+73/zoom+v.sY), 96/zoom, 96/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, v.hoverAlpha))

        local item=items.items[i]
        if(item)then
            if(isMouseInPosition(sw-532/zoom-23/zoom+12/zoom+v.sX, sh/2-487/2/zoom+73/zoom+v.sY, 96/zoom, 96/zoom))then
                local cx,cy=getCursorPosition()
                cx,cy=cx*sw,cy*sh

                dxDrawText(item.name, cx+20/zoom+1, cy+1, 0, 0, tocolor(0,0,0), 1, assets.fonts[2], "left", "top", false, false, true)
                dxDrawText(item.name, cx+20/zoom, cy, 0, 0, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top", false, false, true)
            end

            if(item.skin)then
                if(not ui.preview[item.id])then
                    ui.preview[item.id]={
                        ped=createPed(item.id, 0, 0, 0)
                    }
                    if(not tonumber(item.id))then
                        setElementData(ui.preview[item.id].ped, "custom_name", item.id, false)
                    end

                    ui.preview[item.id].preview=preview:createObjectPreview(ui.preview[item.id].ped, 0, 0, 180, math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-90)/2/zoom, math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-90)/2/zoom, 90/zoom, 90/zoom, false, true, true)
                end
            else
                if(not item.tex)then
                    if(item.type == "item")then
                        dxDrawImage(math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-64)/2/zoom, math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-64)/2/zoom, 64/zoom, 64/zoom, assets.textures[12+i])
                    else
                        dxDrawImage(math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-64)/2/zoom, math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-64)/2/zoom, 64/zoom, 64/zoom, assets.textures[(item.index or 4+i)])
                    end
                else
                    dxDrawText("?", math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-64)/2/zoom, math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-64)/2/zoom, 64/zoom+math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-64)/2/zoom, 64/zoom+math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-64)/2/zoom, tocolor(100, 100, 100), 1, assets.fonts[1], "center", "center")
                end
            end

            onClick(math.floor(sw-532/zoom-23/zoom+12/zoom+v.sX)+(96-64)/2/zoom, math.floor(sh/2-487/2/zoom+73/zoom+v.sY)+(96-64)/2/zoom, 64/zoom, 64/zoom, function()
                if(SPAM.getSpam())then return end

                triggerServerEvent("use.item", resourceRoot, item)
            end)
        end
    end

    onClick(sw-532/zoom-23/zoom+(532-508)/2/zoom+508/zoom-10/zoom, sh/2-487/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)
end

-- functions

ui.create=function()
    blur=exports.blur
    noti=exports.px_noti
    preview=exports.object_preview

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)
end

ui.destroy=function()
    assets.destroy()

    removeEventHandler("onClientRender", root, ui.onRender)

    showCursor(false)

    for i,v in pairs(ui.preview) do
        destroyElement(v.ped)
        destroyElement(v.preview)
    end
    ui.preview={}
end

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function(type)
    ui.infos=type
    ui.create()
end)

function action()
    local faction=getElementData(localPlayer, "user:faction")
    if(faction == "SAPD" or faction == "SARA" or faction == "PSP")then
        ui.infos={faction,"vehicle"}
        ui.create()
    end
end

-- by asper

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh

    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function getPosition(myX, myY, x, y, w, h)
    if(isCursorShowing() and (myX >= x and myX <= (x + w)) and (myY >= y and myY <= (y + h)))then
        return true
    end
    return false
end

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick(x, y, w, h, fnc)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse1") and (mouseClick or mouseState))then
        mouseClick=false
        mouseState=false
    end

    if(mouseState and mouseClicks < 10 and not mouseClick)then
		local cx,cy=unpack(mouseState)
        cx,cy=cx*sw,cy*sh

        if(getPosition(cx, cy, x, y, w, h))then
			fnc()

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end

-- animate

local anims = {}
local rendering = false

local function renderAnimations()
    local now = getTickCount()
    for k,v in pairs(anims) do
        v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
        if(now >= v.start+v.duration)then
            table.remove(anims, k)
			if(type(v.onEnd) == "function")then
                v.onEnd()
            end
        end
    end

    if(#anims == 0)then
        rendering = false
        removeEventHandler("onClientRender", root, renderAnimations)
    end
end

function animate(f, t, easing, duration, onChange, onEnd)
	if(#anims == 0 and not rendering)then
		addEventHandler("onClientRender", root, renderAnimations)
		rendering = true
	end

    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string", "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = easing, duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})

    return #anims
end

function destroyAnimation(id)
    if(anims[id])then
        anims[id] = nil
    end
end

-- rendering

local tex=false
local tick=getTickCount()
local obj=false

function render()
    if(obj and isElement(obj))then
        local x=exports.pAttach:getAttacheds(localPlayer)
        if(not x or (x and #x < 1))then
            local size=0.3
            local x,y,z=getElementPosition(obj)
            z=z+0.5
            z=interpolateBetween(z-0.1, 0, 0, z+0.1, 0, 0, (getTickCount()-tick)/1500, "SineCurve")
            dxDrawMaterialLine3D(x,y,z+size,x,y,z,tex,size,tocolor(255,255,255))
        end
    else
        removeEventHandler("onClientRender", root, render)
        obj=false
    end
end

addEventHandler("onClientElementDataChange", root, function(data,old,new)
    if(data == "factionItem" and source == localPlayer)then
        removeEventHandler("onClientRender", root, render)
        if(new)then
            addEventHandler("onClientRender", root, render)

            obj=new
            tex=dxCreateTexture(":px_jobs-warehouse/textures/buttonQ.png", "argb", false, "clamp")
        else
            if(tex)then
                destroyElement(tex)
            end
        end
    end
end)

-- aodo

local sound=false
local skin=false

function stopSkin()
    local data=getElementModel(localPlayer)
    if(not data or (data ~= skin))then
        removeEventHandler("onClientRender", root, stopSkin)

        destroyElement(sound)
        skin=false
        sound=false
    end
end

addEvent("start.sound", true)
addEventHandler("start.sound", resourceRoot, function(type)
    if(type == "aodo" and not sound)then
        addEventHandler("onClientRender", root, stopSkin)
        
        sound=playSound("aodo_1.wav", true)
        skin=getElementModel(localPlayer)
    end
end)

if(getElementModel(localPlayer) == 278 and not sound)then
    addEventHandler("onClientRender", root, stopSkin)
        
    sound=playSound("aodo_1.wav", true)
    skin=getElementModel(localPlayer)
end