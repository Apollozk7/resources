local punkty_brania_kol={
    {2660.6494,1208.6633,10.8500,tag="LV"},
}

for i,v in ipairs(punkty_brania_kol) do
  v.marker=createMarker(v[1],v[2],v[3],"cylinder", 1.2, 0,0,0,100)
  setElementData(v.marker, "faction:id", v.tag, false)
  setElementData(v.marker, "icon", ":px_workshops/assets/images/tire.png")
  setElementData(v.marker, "pos:z", true)
  setElementData(v.marker, "text", {text="Punkt odbierania opon",desc=""})
end

local function czyPracownikWarsztatu(gracz,tag)
    local data=getElementData(gracz, "user:job_settings")
    if(gracz and data and tag and data.job_tag and data.job_tag == "Warsztat "..tag)then
        return true
    end
    return false
end

local function najblizszeKolo(gracz,pojazd)
  -- easy peasy
  local xg,yg,zg=getElementPosition(gracz)
  local najblizszeKolo=nil
  local najblizszeDist=1000

  local x,y,z=getElementPosition(pojazd)
  local _,_,rz=getElementRotation(pojazd)

  for i=1,4 do
    local rrz=math.rad(rz+45+(i-1)*90)
    local x= x + (1 * math.sin(-rrz))
    local y= y + (1 * math.cos(-rrz))
    if not najblizszeKolo or getDistanceBetweenPoints2D(x,y,xg,yg)<najblizszeDist then
      najblizszeDist=getDistanceBetweenPoints2D(x,y,xg,yg)
      najblizszeKolo=i
    end
  end
  -- ugly
  if not najblizszeKolo then return nil end
  if najblizszeKolo==4 then return 3
  elseif najblizszeKolo==3 then return 4 end
  return najblizszeKolo
end

local function zalozKolo(plr)

  local x,y,z=getElementPosition(plr)
  local _,_,rz=getElementRotation(plr)

  local rrz=math.rad(rz)
  local x= x + (1.5 * math.sin(-rrz))
  local y= y + (1.5 * math.cos(-rrz))

  local cs=createColSphere(x,y,z,2.5)
  local pojazdy=getElementsWithinColShape(cs,"vehicle")
  destroyElement(cs)
  if (#pojazdy~=1) then
    return false
  end

  -- okreslamy, kolo ktorego kola jest gracz

  local k1,k2,k3,k4=getVehicleWheelStates(pojazdy[1])
  if (k1==0) and (k2==0) and (k3==0) and (k4==0) then return end
  local kolo=najblizszeKolo(plr,pojazdy[1])
  if not kolo then return end

  if kolo==1 then
    k1=0
  elseif kolo==2 then
    k2=0
  elseif kolo==3 then
    k3=0
  elseif kolo==4 then
    k4=0
  end

  setPedAnimation(plr, "MISC", "pickup_box", 500, false, false, true, true)
  toggleControl(plr, "forward", false)
  setTimer(function()
    if(plr and isElement(plr) and pojazdy[1] and isElement(pojazdy[1]))then
        toggleControl(plr, "forward", true)
        setPedAnimation(plr, "ped", "phone_in")
        setPedAnimation(plr, false)
        setVehicleWheelStates(pojazdy[1], k1, k2, k3, k4)
        zabierzKolo(plr)
    end
  end, 500, 1)
end

function zabierzKolo(el,delay)
  local niesionyObiekt=getElementData(el,"niesioneKolo")
  if niesionyObiekt then
    if isElement(niesionyObiekt) then
        destroyElement(niesionyObiekt)
    end

    removeElementData(el,"niesioneKolo")
    setPedWalkingStyle(el,0)
    unbindKey(el, "fire", "down", zalozKolo)
    return true
  end
  return false
end

function getTire(el)
  if zabierzKolo(el) then return end

  local kolo=createObject(1337,0,0,0)
  setElementData(kolo, "custom_name", "opona1")
  setObjectScale(kolo, 0.7)
  setElementData(el,"niesioneKolo", kolo,false)
  exports.pAttach:attachElementToBone(kolo,el, 25, 0, -0.1, -0.05, 0, 270, 0)    
  bindKey(el, "fire", "down", zalozKolo)
  setPedWalkingStyle(el,66)
  setElementCollisionsEnabled(kolo,false)
end

addEventHandler("onMarkerHit", resourceRoot, function(el,md)
  if not md or getElementType(el)~="player" then return end

  if zabierzKolo(el) then return end

  if( czyPracownikWarsztatu(el,getElementData(source, "faction:id")) )then
    getTire(el)
  end
end)