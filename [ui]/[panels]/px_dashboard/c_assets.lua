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
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- skalowanie

sw,sh=guiGetScreenSize()

zoom = 1
local fh = 1920

if sw < fh then
  zoom = math.min(2,fh/sw)
end

--

-- variables

ui={}

ui.mainAlpha=0
ui.animate=false

ui.orgAvatar=false

ui.lastTrigger=0

ui.info={}

ui.scroll=false
ui.friends=false
ui.textFriends=""
ui.banner=false

ui.dashboard=false

ui.pages={
    selected=1,
    menu={
        {name="Twój profil", alpha=255},
        {name="Pojazdy", alpha=255},
        {name="Polecanie", alpha=255},
        {name="Osiągnięcia", alpha=255},
        {name="Ustawienia", alpha=255},
        {name="Przewodnik", alpha=255},
        {name="Sklep premium", alpha=255, color={250, 177, 1}},
        {name="Sklep z dodatkami", alpha=255},
        {name="Dzienny bonus", alpha=255}
    },
}

ui.render=false
ui.rendering={}

ui.mapRT=false

ui.buttons={}
ui.scrolls={}
ui.edits={}

-- assets

assets={}
assets.textures={}
assets.fonts={}
assets.list={
    texs={
        ["menu"]={
            "textures/bar_1.png",
            "textures/bar_2.png",
            "textures/bar_3.png",
            "textures/bar_4.png",
            "textures/bar_5.png",
            "textures/bar_6.png",
            "textures/bar_7.png",
            "textures/bar_8.png",
            "textures/bar_9.png",

            "textures/left_selected.png",

            "textures/friends.png",
            "textures/avatar.png",

            "textures/invite_accept.png",
            "textures/invite_cancel.png",
            "textures/delete.png",
        },

        ["Twój profil"]={
            "textures/1/bg.png",
            "textures/1/bg_line.png",

            "textures/1/avatar_bg.png",

            "textures/1/mini-row.png",
            "textures/1/big-row.png",

            "textures/1/circle.png",
            "textures/1/circle-outline.png",

            "textures/1/pj-a.png",
            "textures/1/pj-b.png",
            "textures/1/pj-c.png",
            "textures/1/pj-ce.png",
            "textures/1/pj-l.png",

            "textures/1/money_with.png",
            "textures/1/bank_money.png",
            "textures/1/all_cars.png",
            "textures/1/all_houses.png",

            "textures/1/pj-gun.png",
        },

        ["Pojazdy"]={
            "textures/2/bg.png",
            "textures/2/row.png",
            "textures/2/holder.png",
        },

        ["Polecanie"]={
            "textures/3/row.png",
            "textures/3/copy.png",

            "textures/3/bg.png",
            "textures/3/icon.png",
        },

        ["Osiągnięcia"]={
            "textures/4/bg.png",
            "textures/4/icon.png",
        },

        ["Przewodnik"]={
            "textures/5/button.png",
            "textures/5/circle.png",

            "textures/5/1.png",
            "textures/5/2.png",
            "textures/5/4.png",
            "textures/5/5.png",
            "textures/5/6.png",
            "textures/5/7.png",
            "textures/5/8.png",
            "textures/5/9.png",
            "textures/5/10.png",
        },

        ["Ustawienia"]={
            "textures/6/line.png",
            "textures/6/btn.png",
        },

        ["Sklep z dodatkami"]={
            "textures/7/pp.png",
            "textures/7/random_1.png",
            "textures/7/random_2.png",
            "textures/7/random_icon.png",
            "textures/7/button.png",
            "textures/7/elipse.png",
            "textures/7/elipse_center.png",
        },

        ["Sklep premium"]={
            "textures/7/pp.png",
            "textures/6/line.png",

            "textures/8/row.png",
            "textures/8/bg_sms.png",
            "textures/8/checkbox.png",
            "textures/8/checkbox_selected.png",
            "textures/8/bg_premium.png",
            "textures/8/bg_gold.png",
            "textures/8/corona.png",
            "textures/8/bg_sell.png",
        },

        ["Dzienny bonus"]={
            "textures/9/bg.png",
            "textures/9/shadow.png",
            "textures/9/exp.png",
            "textures/9/money.png",
            "textures/9/pp.png",
            "textures/9/hide.png",
        },
    },

    fonts={
        {"Bold", 13},
        {"Medium", 13},
        {"Medium", 11},
        {"Bold", 10},
        {"Bold", 15},
        {"Regular", 14},
        {"Regular", 13},
        {"Bold", 11},
        {"Bold", 18},
    },
}

assets.create=function(type)
    blur=exports.blur
    logos=exports.px_alogos
    avatars=exports.px_avatars
    noti=exports.px_noti
    scroll=exports.px_scroll
    interaction=exports.px_interaction
    object_preview=exports.object_preview
    buttons=exports.px_buttons
    scroll=exports.px_scroll
    editbox=exports.px_editbox
    
    type=type or "menu"

    assets.textures[type]={}
    for i,v in pairs(assets.list.texs[type]) do
        assets.textures[type][i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.destroy=function(type)
    type=type or "menu"

    if(assets.textures[type])then
        for i,v in pairs(assets.textures[type]) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
    end

    if(type == "menu")then
        assets.textures={}

        for i,v in pairs(assets.fonts) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end
    end
end

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
    if(ui.animate)then return end
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