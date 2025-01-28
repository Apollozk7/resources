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

ui={}

-- assets

edits={
    export=exports.px_editbox,
    objects={}
}

buttons={
    export=exports.px_buttons,
    objects={}
}

scroll={
    export=exports.px_scroll,
    objects={}
}

assets={}
assets.list={
    texs={
        "textures/bar_1.png",
        "textures/bar_2.png",
        "textures/bar_3.png",
        "textures/bar_4.png",

        "textures/window.png",
        "textures/header.png",
        "textures/close.png",
        "textures/left_bar.png",

        "textures/circle.png",
        "textures/job_name.png",
        "textures/start_job.png",

        "textures/row.png",
        "textures/row_2.png",

        "textures/top_1.png",

        "textures/pass.png",
        "textures/del.png",

        "textures/icon_driver.png",
        "textures/icon_worker.png",
    },

    upgrades={
        ["biceps"]="textures/upgrades/upgrade_biceps.png",
        ["forklift"]="textures/upgrades/upgrade_forklift.png",
        ["running"]="textures/upgrades/upgrade_running.png",

        ["fuel_tank_2"]="textures/upgrades/upgrade_tank_2.png",
        ["fuel_tank_3"]="textures/upgrades/upgrade_tank_3.png",

        ["enfoncer_icon"]="textures/upgrades/upgrade_enfoncer.png",
        ["gold_icon"]="textures/upgrades/upgrade_gold.png",
        ["diax_icon"]="textures/upgrades/upgrade_diax.png",

        
        ["pilot_tank_1"]="textures/upgrades/upgrade_pilot_tank_1.png",
        ["pilot_tank_2"]="textures/upgrades/upgrade_pilot_tank_2.png",

        ["mower_tank"]="textures/upgrades/upgrade_mower_tank.png",
        ["mower_tractor"]="textures/upgrades/upgrade_mower_tractor.png",

        ["paczkomaty"]="textures/upgrades/upgrade_paczkomat.png",
        ["car_2"]="textures/upgrades/upgrade_car_2.png",
        ["car_3"]="textures/upgrades/upgrade_car_3.png",
        ["car_4"]="textures/upgrades/upgrade_car_4.png",

        ["truck_car"]="textures/upgrades/icon_upgrade_car.png",
        ["truck_fuel"]="textures/upgrades/icon_upgrade_fuel.png",
        ["truck_wood"]="textures/upgrades/icon_upgrade_wood.png",
        ["offroad"]="textures/upgrades/icon_upgrade_offroad.png",

        ["tractors_1"]="textures/upgrades/icon_tractors_1.png",
        ["tractors_2"]="textures/upgrades/icon_tractors_2.png",
    },

    fonts={
        {"Medium", 13},
        {"Medium", 30},
        {"Regular", 13},
        {"Medium", 15},
        {"Regular", 11},
        {"Bold", 21},
        {"Bold", 13},
        {"Light", 13},
        {"ExtraBold", 11}
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.upgrades={}
    for i,v in pairs(assets.list.upgrades) do
        assets.upgrades[i]=dxCreateTexture(v, "argb", false, "clamp")
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

    for i,v in pairs(assets.upgrades) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.upgrades={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
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

-- variables

ui.info=false
ui.pos={}
ui.rows={}

ui.alpha=0
ui.categoryAlpha=255

ui.border=0

ui.category=1
ui.categories={}

ui.rendering={}
ui.constructor=function(execute, a)
    return ui.rendering[execute](execute, a)
end

ui.selectPage=function(i)
    local v=ui.categories[i]
    if(not v)then return end

    local sY=(42/zoom)*(i-1)

    ui.animate=animate(ui.border, (sh/2-595/2/zoom+sY), "Linear", 250, function(a)
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
        ui.destroyExports()

        ui.category=i
        animate(ui.categoryAlpha, 255, "Linear", 125, function(a)
            ui.categoryAlpha=a
            ui.setExportsAlpha(a)
        end)
    end)
end

ui.onRender=function()
    if(not ui.categories[ui.category])then
        ui.category=1
    end
    
    -- bg
    blur:dxDrawBlur(sw/2-689/2/zoom-42/zoom, sh/2-595/2/zoom, 689/zoom+42/zoom, 595/zoom, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-689/2/zoom, sh/2-595/2/zoom, 689/zoom, 595/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    -- header
    dxDrawImage(sw/2-689/2/zoom, sh/2-595/2/zoom, 689/zoom, 42/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawImage(sw/2-689/2/zoom+689/zoom-10/zoom-(42-10)/2/zoom, sh/2-595/2/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawText(ui.categories[ui.category].name, sw/2-689/2/zoom+42/2/zoom, sh/2-595/2/zoom, 689/zoom, 42/zoom+sh/2-595/2/zoom, tocolor(200, 200, 200, ui.categoryAlpha > ui.alpha and ui.alpha or ui.categoryAlpha), 1, assets.fonts[1], "left", "center")

    -- left bar
    dxDrawImage(sw/2-689/2/zoom-42/zoom, sh/2-595/2/zoom, 42/zoom, 595/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

    -- categories
    for i,v in pairs(ui.categories) do
        local sY=(42/zoom)*(i-1)

        local w,h=dxGetMaterialSize(assets.textures[i])

        v.alpha=v.alpha or (ui.category == i and 255 or 255/2)
        local a=v.alpha > ui.alpha and ui.alpha or v.alpha
        if(ui.category == i)then
            dxDrawImage(sw/2-689/2/zoom-42/zoom+(42-w)/2/zoom, sh/2-595/2/zoom+sY+(42-h)/2/zoom, w/zoom, h/zoom, assets.textures[i], 0, 0, 0, tocolor(255, 255, 255,a))

            if(ui.border == 0)then
                ui.border=sh/2-595/2/zoom+sY
            end

            ui.constructor(v.execute, ui.categoryAlpha > ui.alpha and ui.alpha or ui.categoryAlpha)
        else
            dxDrawImage(sw/2-689/2/zoom-42/zoom+(42-w)/2/zoom, sh/2-595/2/zoom+sY+(42-h)/2/zoom, w/zoom, h/zoom, assets.textures[i], 0, 0, 0, tocolor(255, 255, 255,a))
        end

        dxDrawRectangle(sw/2-689/2/zoom-42/zoom, sh/2-595/2/zoom+sY+42/zoom-1, 42/zoom, 1, tocolor(75,75,75, ui.alpha))

        onClick(sw/2-689/2/zoom-42/zoom, sh/2-595/2/zoom+sY, 42/zoom, 42/zoom, function()
            if(not ui.animate and ui.category ~= i)then
                ui.selectPage(i)
            end
        end)
    end

    -- border line
    dxDrawRectangle(sw/2-689/2/zoom-1, ui.border, 1, 42/zoom, tocolor(56,164,214, ui.alpha))

    -- close
    onClick(sw/2-689/2/zoom+689/zoom-10/zoom-(42-10)/2/zoom, sh/2-595/2/zoom+(42-10)/2/zoom, 10/zoom, 10/zoom, function()
        ui.destroy()
    end)
end

ui.create=function()
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    blur=exports.blur
    noti=exports.px_noti
    avatars=exports.px_avatars

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)

    ui.animate=true
    animate(ui.alpha, 255, "Linear", 200, function(a)
        ui.alpha=a
        ui.setExportsAlpha(a)
    end, function()
        ui.animate=false
    end)

    local screen_path=":"..ui.info.sql.scriptName.."/textures/job_screen.png"
    if(fileExists(screen_path))then
        assets.textures[#assets.textures+1]=dxCreateTexture(screen_path,"argb",false,"clamp")
    end

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    setElementFrozen(localPlayer, true)

    toggleControl("enter_exit", false)
end

ui.destroy=function()
    ui.quitLobby()
    ui.selectedCoop=false

    ui.animate=true
    animate(ui.alpha, 0, "Linear", 200, function(a)
        ui.alpha=a
        ui.setExportsAlpha(a)
    end, function()
        assets.destroy()

        removeEventHandler("onClientRender", root, ui.onRender)
    
        showCursor(false)
    
        ui.animate=false

        ui.destroyExports()

        ui.info=false

        ui.lobbys={}

        setElementData(localPlayer, "user:gui_showed", false, false)

        toggleControl("enter_exit", true)
    end)

    setElementFrozen(localPlayer, false)
end

addEvent("open.job", true)
addEventHandler("open.job", resourceRoot, function(data, lobbys)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    ui.categories={
        {name="Informacje", execute="info"},
        {name="Ranking", execute="ranking"},
        {name="Ulepszenia", execute="upgrades"},
    }

    if(data.sql["co-op"] and data.sql["co-op"] ~= 0)then
        ui.categories[#ui.categories+1]={name="Praca grupowa", execute="coop"}
    end

    ui.info=data
    ui.lobbys=lobbys

    ui.create()
end)

addEvent("update.myRanking", true)
addEventHandler("update.myRanking", resourceRoot, function(myRanking, upgrade)
    if(myRanking)then
        ui.info.myRanking=myRanking
    end

    if(upgrade)then
        for i,v in pairs(buttons.objects) do
            buttons.export:destroyButton(v)
        end
        buttons.objects={}
    end
end)

addEvent("destroy.window", true)
addEventHandler("destroy.window", resourceRoot, function()
    ui.destroy()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
        setElementFrozen(localPlayer, false)
    end
end)

-- mouse

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
	if(not isCursorShowing() or ui.animate)then return end

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

--

-- animate

anims = {}
rendering = false 

function renderAnimations()
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