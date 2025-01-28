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


-- global variables

sw,sh=guiGetScreenSize()
zoom=1920/sw

-- variables

ui={}

ui.logo=false

ui.alpha=255
ui.categoryAlpha=255

ui.opened=false

ui.category=1
ui.categories={
    {name="Statystyki", execute="stats"},
    {name="Gracze", execute="users"},
    {name="Mapa", execute="map"},
    {name="Rangi", execute="ranks"},
    {name="Zadania dzienne", execute="tasks"},
    {name="Ulepszenia", execute="upgrades"},
}

ui.border=0

ui.sql=false

-- bars

ui.barsAssets={}
ui.rendering={}
ui.constructor=function(execute, a)
    return ui.rendering[execute](execute, a)
end

ui.getTextures=function(execute)
    return ui.barsAssets.textures[execute], ui.barsAssets.textures["icons"]
end

ui.updateRenderTarget=function(update)
    dxSetRenderTarget(ui.renderTarget, true)
        update()
    dxSetRenderTarget()
end

ui.barsAssets.list={
    ["stats"]={
        "textures/bars/stats/logo_bg.png",
        "textures/bars/stats/logo_bg2.png",
        "textures/bars/stats/logo_outline.png",

        "textures/bars/stats/xp_bg.png",

        "textures/bars/stats/bg.png",
        "textures/bars/stats/bg2.png",

        "textures/bars/stats/group-icon.png",
        "textures/bars/stats/vehs-icon.png",
        "textures/bars/stats/rising-icon.png",
        "textures/bars/stats/activity-icon.png",
    },
    
    ["users"]={
        "textures/bars/users/list.png",

        "textures/bars/users/row.png",
        "textures/bars/users/rozwin.png",
        "textures/bars/users/zwin.png",

        "textures/bars/users/checkbox.png",
        "textures/bars/users/checkbox_selected.png",
    },

    ["ranks"]={
        "textures/bars/users/list.png",
        "textures/bars/users/row.png",
    },

    ["map"]={
        "textures/bars/map/car.png",
        "textures/bars/map/house.png",
        "textures/bars/map/player.png",
    },

    ["tasks"]={
        "textures/bars/tasks/progress-bg.png",
        "textures/bars/tasks/task-bg.png",
        "textures/bars/tasks/task-bg2.png",

        "textures/bars/tasks/check.png",
        "textures/bars/tasks/no_active.png",
    },

    ["icons"]={
        ["dollar"]="textures/icons/dollar.png",
        ["fuel"]="textures/icons/fuel.png",
        ["hours"]="textures/icons/hours.png",
        ["job"]="textures/icons/job.png",
        ["mandate"]="textures/icons/mandate.png",
        ["vehs"]="textures/icons/vehs.png",
        ["users"]="textures/icons/users.png",
    }
}

-- assets

edits={
    objects={}
}

buttons={
    objects={}
}

scroll={
    objects={},
    pos=0
}

assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/header.png",
        "textures/close.png",
        "textures/left_bar.png",
        "textures/logo_bg.png",

        "textures/bar_1.png",
        "textures/bar_2.png",
        "textures/bar_3.png",
        "textures/bar_4.png",
        "textures/bar_5.png",
        "textures/bar_6.png",

        "textures/left_logo.png",
        "textures/logo.png",

        "textures/exit.png",

        "textures/loading.png",
    },

    fonts={
        {"Medium", 13},
        {"Medium", 30},
        {"Regular", 13},
        {"Medium", 15},
        {"Regular", 11},
        {"Bold", 13},
        {"Bold", 15},
        {"Bold", 10},
        {"Light", 13},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom, false, "default")
    end

    ui.barsAssets.textures={}
    for i,v in pairs(ui.barsAssets.list) do
        if(not ui.barsAssets.textures[i])then
            ui.barsAssets.textures[i]={}
        end

        for k,v in pairs(v) do
            ui.barsAssets.textures[i][k]=dxCreateTexture(v, "argb", false, "clamp")
        end
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

    for i,v in pairs(ui.barsAssets.textures) do
        for i,v in pairs(v) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
    end
    ui.barsAssets.textures={}
end

ui.destroyExports=function()
    for i,v in pairs(edits.objects) do
        edits.export:dxDestroyEdit(v)
    end
    edits.objects={}

    for i,v in pairs(buttons.objects) do
        buttons.export:destroyButton(v)
    end
    buttons.objects={}

    for i,v in pairs(scroll.objects) do
        scroll.export:dxDestroyScroll(v)
    end
    scroll.objects={}
end

ui.setExportsAlpha=function(a)
    for i,v in pairs(edits.objects) do
        edits.export:dxSetEditAlpha(v,a)
    end
    for i,v in pairs(buttons.objects) do
        buttons.export:buttonSetAlpha(v,a)
    end
    for i,v in pairs(scroll.objects) do
        scroll.export:dxScrollSetAlpha(v,a)
    end
end

-- rendering

ui.onRender=function()
    -- bg
    blur:dxDrawBlur(sw/2-730/2/zoom, sh/2-581/2/zoom, 730/zoom, 581/zoom, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-730/2/zoom, sh/2-581/2/zoom, 730/zoom, 581/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    -- header
    dxDrawImage(sw/2-730/2/zoom, sh/2-581/2/zoom, 730/zoom, 42/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-730/2/zoom+730/zoom-10/zoom-(42-10)/2/zoom, sh/2-581/2/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawText(ui.categories[ui.category].name, sw/2-730/2/zoom+42/zoom+42/2/zoom, sh/2-581/2/zoom, 730/zoom, 42/zoom+sh/2-581/2/zoom, tocolor(200, 200, 200, ui.categoryAlpha > ui.alpha and ui.alpha or ui.categoryAlpha), 1, assets.fonts[1], "left", "center")

    -- left bar
    dxDrawImage(sw/2-730/2/zoom, sh/2-581/2/zoom, 42/zoom, 581/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-730/2/zoom, sh/2-581/2/zoom, 42/zoom, 42/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-730/2/zoom+(42-24)/2/zoom, sh/2-581/2/zoom+(42-24)/2/zoom, 24/zoom, 24/zoom, assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    if(ui.logo)then
        dxDrawImage(sw/2-730/2/zoom+(42-24)/2/zoom, sh/2-581/2/zoom+(42-24)/2/zoom, 24/zoom, 24/zoom, ui.logo, 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    else
        dxDrawImage(sw/2-730/2/zoom+(42-8)/2/zoom, sh/2-581/2/zoom+(42-10)/2/zoom, 8/zoom, 10/zoom, assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    end

    -- categories
    for i,v in pairs(ui.categories) do
        local sY=(42/zoom)*(i-1)

        local w,h=dxGetMaterialSize(assets.textures[5+i])

        v.alpha=v.alpha or (ui.category == i and 255 or 255/2)
        local a=v.alpha > ui.alpha and ui.alpha or v.alpha
        if(ui.category == i)then
            dxDrawImage(sw/2-730/2/zoom+(42-w)/2/zoom, sh/2-581/2/zoom+42/zoom+sY+(42-h)/2/zoom, w/zoom, h/zoom, assets.textures[5+i], 0, 0, 0, tocolor(255, 255, 255,v.alpha))

            if(ui.border == 0)then
                ui.border=sh/2-581/2/zoom+42/zoom+sY
            end

            if(not ui.sql)then 
                ui.rendering["loading"](ui.categoryAlpha > ui.alpha and ui.alpha or ui.categoryAlpha)
            else
                ui.constructor(v.execute, ui.categoryAlpha > ui.alpha and ui.alpha or ui.categoryAlpha)
            end
        else
            dxDrawImage(sw/2-730/2/zoom+(42-w)/2/zoom, sh/2-581/2/zoom+42/zoom+sY+(42-h)/2/zoom, w/zoom, h/zoom, assets.textures[5+i], 0, 0, 0, tocolor(255, 255, 255,v.alpha))
        end

        dxDrawRectangle(sw/2-730/2/zoom, sh/2-581/2/zoom+42/zoom+sY+42/zoom-1, 42/zoom, 1, tocolor(75,75,75, ui.alpha))

        onClick(sw/2-730/2/zoom, sh/2-581/2/zoom+42/zoom+sY, 42/zoom, 42/zoom, function()
            if(not ui.animate and ui.category ~= i)then
                ui.animate=animate(ui.border, (sh/2-581/2/zoom+42/zoom+sY), "Linear", 250, function(a)
                    ui.border=a
                end,function()
                    ui.animate=nil
                end)

                local last=ui.categories[ui.category]
                if(last)then
                    animate(last.alpha, 255/2, "Linear", 125, function(a)
                        last.alpha=a
                    end)
                end

                animate(v.alpha, 255, "Linear", 125, function(a)
                    v.alpha=a
                end)

                animate(ui.categoryAlpha, 0, "Linear", 125, function(a)
                    ui.categoryAlpha=a
                    ui.setExportsAlpha(a)
                end, function()
                    if(ui.renderTarget and isElement(ui.renderTarget))then
                        destroyElement(ui.renderTarget)
                        ui.renderTarget=false
                    end

                    ui.destroyExports()

                    ui.category=i
                    animate(ui.categoryAlpha, 255, "Linear", 125, function(a)
                        ui.categoryAlpha=a
                        ui.setExportsAlpha(a)
                    end)
                end)
            end
        end)
    end

    local w,h=dxGetMaterialSize(assets.textures[14])
    dxDrawImage(sw/2-730/2/zoom+(42-w)/2/zoom, sh/2-581/2/zoom+581/zoom-30/zoom, w/zoom, h/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255,ui.alpha))
    onClick(sw/2-730/2/zoom+(42-w)/2/zoom, sh/2-581/2/zoom+581/zoom-30/zoom, w/zoom, h/zoom, function()
        if(SPAM.getSpam())then return end

        triggerServerEvent("leave.org", resourceRoot)
    end)

    -- border line
    dxDrawRectangle(sw/2-730/2/zoom+42/zoom-1, ui.border, 1, 42/zoom, tocolor(56,164,214, ui.alpha))

    -- close
    onClick(sw/2-730/2/zoom+730/zoom-10/zoom-(42-10)/2/zoom, sh/2-581/2/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, function()
        removeEventHandler("onClientRender", root, ui.onRender)

        assets.destroy()

        showCursor(false)

        ui.opened=false
        ui.sql=false

        ui.destroyExports()

        setElementData(localPlayer, "user:gui_showed", false, false)
    end)
end

ui.rot=0
ui.rendering["loading"]=function(a)
    ui.rot=ui.rot-2
    dxDrawImage(sw/2-730/2/zoom+42/zoom+((730-42)-70)/2/zoom, sh/2-581/2/zoom+42/zoom+((581-42)-70)/2/zoom, 70/zoom, 70/zoom, assets.textures[15], ui.rot, 0, 0, tocolor(255, 255, 255, a))
    dxDrawText("TRWA WCZYTYWANIE INFORMACJI...", sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+150/zoom, sw/2-730/2/zoom+730/zoom, sh/2-581/2/zoom+581/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], "center", "center")
end

-- triggers

bindKey("F4", "down", function()
    if(ui.opened)then
        removeEventHandler("onClientRender", root, ui.onRender)

        assets.destroy()

        showCursor(false)

        ui.opened=false
        ui.sql=false

        ui.destroyExports()

        setElementData(localPlayer, "user:gui_showed", false, false)

        ui.map=false
    else
        local org=getElementData(localPlayer, "user:organization")
        if(org)then
            if(SPAM.getSpam())then return end

            if(getElementData(localPlayer, "user:gui_showed"))then return end

            edits.export=exports.px_editbox
            buttons.export=exports.px_buttons
            scroll.export=exports.px_scroll
            blur=exports.blur

            assets.create()

            addEventHandler("onClientRender", root, ui.onRender)

            showCursor(true)

            triggerServerEvent("openManagementPanel", resourceRoot)

            ui.opened=true

            setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
        end
    end
end)

addEvent("update.management.panel", true)
addEventHandler("update.management.panel", resourceRoot, function(q,users,org,online,vehs,task,tasks,upgrades,lvl_up,logo)
    ui.sql={
        myInfo=q,
        users=users,
        org=org,
        online=online,
        vehs=vehs,
        task=task,
        tasks=tasks,
        upgrades=upgrades,
        lvl_up=lvl_up
    }

    if(ui.renderTarget and isElement(ui.renderTarget))then
        destroyElement(ui.renderTarget)
        ui.renderTarget=false
    end
end)

addEvent("load.avatar", true)
addEventHandler("load.avatar", resourceRoot, function(logo)
    if(logo)then
        ui.logo=dxCreateTexture(logo, "argb", false, "clamp")
        ui.logo=exports.px_avatars:getCircleTexture(ui.logo)
    end
end)

-- useful

function convertMinutes(minutes)
    local h = math.floor(minutes/60)
    local m = math.floor(minutes-(h*60))
    return h,m
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

-- useful function created by Asper

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
function onClick(x, y, w, h, fnc, key)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState(key or "mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState(key or "mouse1") and (mouseClick or mouseState))then
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

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function formatNumber(number)
    local sep=","
	local money = number
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1"..sep.."%2")
	end
	return money
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)