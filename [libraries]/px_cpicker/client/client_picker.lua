--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI={}
UI.texs={}

function createPicker(x,y,w,h,left)
  UI.texs={
    dxCreateTexture("assets/images/sv.png", "argb", false, "clamp"),
    dxCreateTexture("assets/images/h.png", "argb", false, "clamp"),
    dxCreateTexture("assets/images/cursor.png", "argb", false, "clamp"),
    dxCreateTexture("assets/images/select_1.png", "argb", false, "clamp"),
    dxCreateTexture("assets/images/select_2.png", "argb", false, "clamp"),
  }

  UI.pos={x,y,w,h}
  UI.cpos={UI.pos[1]+14/2/zoom,UI.pos[2]+14/2/zoom}
  
  UI.hpos={UI.pos[1]+UI.pos[3]+14/zoom,UI.pos[2],left,h}
  UI.chpos=0
  
  UI.color={0,0,0}

  addEventHandler("onClientRender", root, UI.onRender)
end

function destroyCPicker()
  removeEventHandler("onClientRender", root, UI.onRender)

  for i,v in pairs(UI.texs) do
    destroyElement(v)
  end
  UI.texs={}
end

function getCPickerSelectedColor()
  return unpack(UI.color)
end

UI.onRender=function()
  if(not isCursorShowing())then return end

  local cx,cy=getCursorPosition()
  cx,cy=cx*sw,cy*sh

  -- colors checker

  local o=cy-UI.pos[2]
  local h=(UI.pos[4]-o)/UI.pos[4]
  local ox,oy=UI.cpos[1]-UI.pos[1],UI.cpos[2]-UI.pos[2]
  local cs=ox/UI.pos[3]
  local cv=(UI.pos[3]-oy)/UI.pos[3]

  -- RIGHT PALETTE
  dxDrawImage(UI.hpos[1], UI.hpos[2], UI.hpos[3], UI.hpos[4], UI.texs[2])
  if(isMouseInPosition(UI.hpos[1], UI.hpos[2], UI.hpos[3], UI.hpos[4]))then
    if(getKeyState("mouse1"))then
      UI.chpos=h
      UI.color={hsv2rgb(h, cs, cv)}
    end
  end

  dxDrawImage(UI.hpos[1]-(26/zoom-UI.hpos[3])/2, UI.hpos[2]-(UI.pos[4]*UI.chpos)+UI.pos[4]-26/2/zoom, 26/zoom, 26/zoom, UI.texs[5], 0, 0, 0, tocolor(hsv2rgb(UI.chpos, 1, 1)))
  dxDrawImage(UI.hpos[1]-(26/zoom-UI.hpos[3])/2, UI.hpos[2]-(UI.pos[4]*UI.chpos)+UI.pos[4]-26/2/zoom, 26/zoom, 26/zoom, UI.texs[4])

  -- MAIN PALETTE
  dxDrawRectangle(UI.pos[1]-1, UI.pos[2]-1, UI.pos[3]+2, UI.pos[4]+2, tocolor(54,55,52))
  dxDrawRectangle(UI.pos[1], UI.pos[2], UI.pos[3], UI.pos[4],tocolor(hsv2rgb(UI.chpos, 1, 1)))
  dxDrawImage(UI.pos[1], UI.pos[2], UI.pos[3], UI.pos[4], UI.texs[1])
  if(isMouseInPosition(UI.pos[1], UI.pos[2], UI.pos[3], UI.pos[4]))then
    if(getKeyState("mouse1"))then
      UI.cpos={cx,cy}

      ox,oy=UI.cpos[1]-UI.pos[1],UI.cpos[2]-UI.pos[2]
      cs=ox/UI.pos[3]
      cv=(UI.pos[3]-oy)/UI.pos[3]

      UI.color={hsv2rgb(UI.chpos, cs, cv)}
    end
  end

  dxDrawImage(UI.cpos[1]-22/2/zoom,UI.cpos[2]-22/2/zoom,22/zoom,22/zoom,UI.texs[3])
end

--createPicker(sw/2-192/2/zoom, sh/2-192/2/zoom, 192/zoom, 192/zoom, 14/zoom)
--showCursor(true,false)

-- useful

function hsv2rgb(h, s, v)
  local r, g, b
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
  local switch = i % 6
  if switch == 0 then
    r = v g = t b = p
  elseif switch == 1 then
    r = q g = v b = p
  elseif switch == 2 then
    r = p g = v b = t
  elseif switch == 3 then
    r = p g = q b = v
  elseif switch == 4 then
    r = t g = p b = v
  elseif switch == 5 then
    r = v g = p b = q
  end
  return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
        return true
    else
        return false
    end
end