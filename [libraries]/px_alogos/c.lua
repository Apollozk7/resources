--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local logos={
    "logos/x-mint.png",
    "logos/x-full.png",
    "logos/x-lavenda.png",
    "logos/x-orange.png",
    "logos/x-yellow.png",
    "logos/x-white.png",

    "logos/m-mint.png",
    "logos/m-full.png",
    "logos/m-lavenda.png",
    "logos/m-orange.png",
    "logos/m-yellow.png",
    "logos/m-white.png",
}

for i,v in pairs(logos) do
    logos[i]=dxCreateTexture(v, "argb", false, "clamp")
end

local logo_new=2
local logo=1
local logo_a=255
local logo_a2=0

function dxDrawLogo(x,y,w,h,alpha,postGUI)
    alpha=alpha or 255

    dxDrawImage(x,y,w,h,logos[logo],0,0,0,tocolor(255,255,255,alpha > logo_a and logo_a or alpha),postGUI)
    if(logo_new > 0)then
        dxDrawImage(x,y,w,h,logos[logo_new],0,0,0,tocolor(255,255,255,alpha > logo_a2 and logo_a2 or alpha),postGUI)
    end
end

function dxDrawMiniLogo(x,y,w,h,alpha,postGUI)
    alpha=alpha or 255

    dxDrawImage(x,y,w,h,logos[6+logo],0,0,0,tocolor(255,255,255,alpha > logo_a and logo_a or alpha),postGUI)
    if(logo_new > 0)then
        dxDrawImage(x,y,w,h,logos[6+logo_new],0,0,0,tocolor(255,255,255,alpha > logo_a2 and logo_a2 or alpha),postGUI)
    end
end

function logoAnimate()
    animate(logo_a, 0, "Linear", 1000, function(a)
        logo_a=a
    end, function()
        logo=logo_new
        logo_a=255
        logo_a2=0
        logo_new=(logo+1) == 7 and 1 or logo+1

        setTimer(function()
            logoAnimate()
        end, 500, 1)
    end)
    
    animate(0, 255, "Linear", 500, function(a)
        logo_a2=a
    end)
end
setTimer(function()
    logoAnimate()
end, 500, 1)

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
