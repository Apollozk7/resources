--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPEEDO.getInfo=function(text,key,texs,icon,pos, m)
    dxDrawImage(pos[1], pos[2]-m[3], m[1], m[1], getKeyState(key) and texs[icon+1] or texs[icon])

    dxDrawText(text, pos[1]+1, pos[2]-m[3]-m[2]+1, m[1]+pos[1]+1, m[1]+1, tocolor(0, 0, 0), 1, SPEEDO.fonts[7][3], "center", "top")
    dxDrawText(text, pos[1], pos[2]-m[3]-m[2], m[1]+pos[1], m[1], tocolor(200, 200, 200), 1, SPEEDO.fonts[7][3], "center", "top")
end

SPEEDO.render_7=function(vehicle)
    local self=SPEEDO.TEXTURES[7].positions
    local texs=SPEEDO.TEXTURES[7]
    local fonts=SPEEDO.fonts[7]
    local speed=getElementSpeed(vehicle, 1)
    if(self)then
        local fuel,bak=SPEEDO.getFuel(vehicle)

        dxDrawImage(self.cockpit[1], self.cockpit[2], self.cockpit[3], self.cockpit[4], texs[1], 0, 0, 0, tocolor(255,255,255,255))

        local hp=getElementHealth(vehicle)/10
        dxDrawImageSection(self.destruction[1], self.destruction[2], self.destruction[3]*(hp/100), self.destruction[4], 0, 0, self.destruction[6]*(hp/100), self.destruction[7], texs[2], 0, 0, 0, tocolor(255,255,255,255))
        dxDrawText(math.floor(100-hp).."%", self.destruction[1]+1, self.destruction[2]+1, self.destruction[3]+self.destruction[1]+1, self.destruction[4]+self.destruction[2]-self.destruction[5]+1, tocolor(0, 0, 0), 1, fonts[2], "center", "center")
        dxDrawText(math.floor(100-hp).."%", self.destruction[1], self.destruction[2], self.destruction[3]+self.destruction[1], self.destruction[4]+self.destruction[2]-self.destruction[5], tocolor(200, 200, 200), 1, fonts[2], "center", "center")

        if(getVehicleEngineState(vehicle))then
            dxDrawImage(self.engine[1], self.engine[2], self.engine[3], self.engine[4], texs[6], 0, 0, 0, tocolor(255,255,255,255))
        else
            dxDrawImage(self.engine[1], self.engine[2], self.engine[3], self.engine[4], texs[7], 0, 0, 0, tocolor(255,255,255,255))

            if(getVehicleController(vehicle) == localPlayer)then
                SPEEDO.getInfo("Uruchom silnik", "K", texs, 10, self.engine, self.buttonMinus)
            end
        end

        if(getVehicleName(vehicle) == "Dodo" and getVehicleController(vehicle) == localPlayer)then
            local banner=exports["px_jobs-pilot-l1"]:isHaveBanner()
            if(banner)then
                dxDrawImage(self.banner[1], self.banner[2], self.banner[3], self.banner[4], texs[4], 0, 0, 0, tocolor(255,255,255,255))
            else
                dxDrawImage(self.banner[1], self.banner[2], self.banner[3], self.banner[4], texs[5], 0, 0, 0, tocolor(255,255,255,255))
                SPEEDO.getInfo("Wysuń banner", "X", texs, 8, self.banner, self.buttonMinus)
            end

            local info=exports["px_jobs-pilot-l1"]:getBannerInfo()
            dxDrawText(info, self.info[1], self.info[2], self.info[3], self.info[4], tocolor(255, 255, 255), 1, fonts[2], "center", "top")
        end

        dxDrawImage(self.fuel[1]+self.fuel_pointer*(fuel/bak), self.fuel[2], self.fuel[3], self.fuel[4], texs[3], 0, 0, 0, tocolor(255,255,255,255))

        dxDrawText(math.floor(speed).." KMPH", self.speed[1], self.speed[2], self.speed[3], self.speed[4], tocolor(15, 117, 9), 1, fonts[1], "center", "top")
    end
end

bindKey("K", "down", function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then return end

    if(SPEEDO.getVehicleSpeedoType(veh) == 7 and getVehicleController(veh) == localPlayer)then
        setVehicleEngineState(veh, not getVehicleEngineState(veh))
    end
end)