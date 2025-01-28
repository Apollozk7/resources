--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- plates

local plates={}

local font=dxCreateFont("assets/digital-7.ttf", 10)
local font2=dxCreateFont("assets/digital-7.ttf", 20)
local texs={
  dxCreateTexture("assets/license_background.png", "argb", false, "clamp"),
  dxCreateTexture("assets/license_overlay_1.png", "argb", false, "clamp"),
  dxCreateTexture("assets/license_overlay.png", "argb", false, "clamp"),
}

function getPlateRT(text, color)
  local w2,h2=200,150
  local rt=dxCreateRenderTarget(w2,h2,true)

  color=color or {0,0,0}

  dxSetRenderTarget(rt, true)
    dxDrawRectangle(0, 0, w2,h2, tocolor(222,222,222))
    dxDrawImage(0, 0, w2,h2, "assets/bg.png", 0, 0, 0, tocolor(255, 255, 255, 100))
    dxDrawImage(0, 0, w2,h2, texs[1], 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawImage(0, 0, w2,h2, texs[2], 0, 0, 0, tocolor(color[1], color[2], color[3], 255))
    dxDrawImage(0, 0, w2,h2, texs[3], 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText(text, 0, 22, w2, h2, tocolor(30,30,30), 1, font2, "center", "center")
  dxSetRenderTarget()

  return rt
end

function applyShader(veh)
  if(veh and isElement(veh))then
    local plateText=getVehiclePlateText(veh) or "?"
    local data=getElementData(veh, "vehicle:plateColor") or {100,100,100}
    local r,g,b=unpack(data)

    local w2,h2=200,150
    local w,h=90,17

    if(not plates[veh])then
      plates[veh]={
        rt=dxCreateRenderTarget(w2,h2,true),
        rt2=dxCreateRenderTarget(w,h,true),

        s=dxCreateShader("assets/shader.fx"),
        s2=dxCreateShader("assets/shader.fx"),
      }
    end

    dxSetRenderTarget(plates[veh].rt)
      dxDrawRectangle(0, 0, w2,h2, tocolor(222,222,222))
      dxDrawImage(0, 0, w2,h2, "assets/bg.png", 0, 0, 0, tocolor(255, 255, 255, 100))
      dxDrawImage(0, 0, w2,h2, texs[1], 0, 0, 0, tocolor(255, 255, 255, 255))
      dxDrawImage(0, 0, w2,h2, texs[2], 0, 0, 0, tocolor(r, g, b, 255))
      dxDrawImage(0, 0, w2,h2, texs[3], 0, 0, 0, tocolor(255, 255, 255, 255))
    dxSetRenderTarget()
    dxSetShaderValue(plates[veh].s, "shader", plates[veh].rt)
    for i=1,5 do
      engineApplyShaderToWorldTexture(plates[veh].s, "plateback"..i, veh)
    end

    dxSetRenderTarget(plates[veh].rt2)
      dxDrawRectangle(0, 0, w, h, tocolor(222,222,222))
      dxDrawImage(0, 0, w, h, "assets/bg.png", 0, 0, 0, tocolor(255, 255, 255, 150))

      dxDrawText(plateText, 0, 0, w, h, tocolor(30,30,30), 1, font, "center", "center")

      dxDrawImage(0, 0, w, h, "assets/bg.png", 0, 0, 0, tocolor(255, 255, 255, 10))
    dxSetRenderTarget()
    dxSetShaderValue(plates[veh].s2, "shader", plates[veh].rt2)
    engineApplyShaderToWorldTexture(plates[veh].s2, "custom_car_plate", veh)
  end
end

function destroyShader(veh)
  if(veh and isElement(veh) and plates[veh])then
    for i,v in pairs(plates[veh]) do
      destroyElement(v)
    end
    plates[veh]=nil
  end
end

addEventHandler("onClientElementStreamIn", root, function()
  if(getElementType(source) == "vehicle")then
    setTimer(applyShader, 500, 1, source)
  end
end)

addEventHandler("onClientElementStreamOut", root, function()
  if(getElementType(source) == "vehicle")then
    destroyShader(source)
  end
end)

addEventHandler("onClientElementDestroy", root, function()
  if(getElementType(source) == "vehicle")then
    destroyShader(source)
  end
end)

addEventHandler("onClientRestore", root, function()
  for i,v in pairs(getElementsByType("vehicle", true)) do
    applyShader(v)
  end
end)

addEventHandler("onClientElementDataChange", root, function(data, _, new)
  if(getElementType(source) == "vehicle" and data == "vehicle:plateColor")then
    applyShader(source)
  end
end)

for i,v in pairs(getElementsByType("vehicle", true)) do
  applyShader(v)
end

addCommandHandler("plate", function(_, r, g, b)
  local v=getPedOccupiedVehicle(localPlayer)
  if(v)then
    setElementData(v, "vehicle:plateColor", {r,g,b})
  end
end)