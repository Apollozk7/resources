--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(veh)
    local target = getVehicleController(veh)
    if(target and isElement(target))then
        triggerClientEvent(target, "set:spray", resourceRoot, veh, client)
    end
end)

addEvent("notis", true)
addEventHandler("notis", resourceRoot, function(text, player)
    noti=exports.px_noti

    exports.px_noti:noti(text,player)
end)

addEvent("give:spray", true)
addEventHandler("give:spray", resourceRoot, function(player, veh, color)
    if(getPlayerMoney(client) >= 150)then
        takePlayerMoney(client, 150)

        if(#getPedWeapons(player) == 0)then
            giveWeapon(player,41,9999,true)
        end

        setElementData(player, "color:spray", {
            color=color,
            veh=veh
        })

        givePlayerMoney(player, 75)

        local data=getElementData(player, "user:job_settings")
        if(data)then
            data.money=(data.money or 0)+75
            setElementData(player, "user:job_settings", data)
        end

        exports.px_noti:noti("Pomyślnie przyjęto oferte malowania od gracza "..getPlayerName(player)..".", client, "success")
        exports.px_noti:noti(getPlayerName(client).." przyjął oferte malowania.", player, "success")
    else
        exports.px_noti:noti("Nie stać Cię na malowanie pojazdu.", client, "error")
    end
end)

function setColor(player,vehicle,cr,cg,cb,cr2,cg2,cb2,cr3,cg3,cb3)
    local r,g,b,r2,g2,b2,r3,g3,b3=getVehicleColor(vehicle, true)

    if (r<cr) then			r=r+1		elseif (r>cr) then			r=r-1		end
    if (g<cg) then			g=g+1		elseif (g>cg) then			g=g-1		end
    if (b<cb) then			b=b+1		elseif (b>cb) then			b=b-1		end

    if (r2<cr2) then			r2=r2+1		elseif (r2>cr2) then			r2=r2-1		end
    if (g2<cg2) then			g2=g2+1		elseif (g2>cg2) then			g2=g2-1		end
    if (b2<cb2) then			b2=b2+1		elseif (b2>cb2) then			b2=b2-1		end

    if (r3<cr3) then			r3=r3+1		elseif (r3>cr3) then			r3=r3-1		end
    if (g3<cg3) then			g3=g3+1		elseif (g3>cg3) then			g3=g3-1		end
    if (b3<cb3) then			b3=b3+1		elseif (b3>cb3) then			b3=b3-1		end

    setVehicleColor(vehicle, r,g,b, r2,g2,b2, r3,g3,b3)

    if(r==cr and cg==g and cb==b and cr2==r2 and cg2==g2 and cb2==b2 and cr3==r3 and cg3==g3 and cb3==b3)then
        local data=getElementData(player, "color:spray")
        exports.px_noti:noti("Pomyślnie pomalowano pojazd.", player)

        takeWeapon(player,41)

        if(data.color)then
            setVehicleColor(vehicle, unpack(data.color))
        end

        if(data)then
            setElementData(player, "color:spray", false)
        end

        local controller=getVehicleController(vehicle)
        if(controller)then
            toggleControl(controller, 'accelerate', true)
            toggleControl(controller, 'enter_exit', true)
            toggleControl(controller, 'brake_reverse', true)
            toggleControl(controller, 'forwards', true)
            toggleControl(controller, 'backwards', true)
            toggleControl(controller, 'left', true)
            toggleControl(controller, 'right', true)

            exports.px_noti:noti("Pomyślnie pomalowano pojazd.", controller)
        end
    end
end

addEvent("set:color", true)
addEventHandler("set:color", resourceRoot, function(vehicle)
    local spray=getElementData(client,"color:spray")
    if(spray and spray.veh and spray.veh == vehicle)then
        setColor(client,vehicle,unpack(spray.color))
    end
end)

-- useful

function RGBToHex(red, green, blue, alpha)

	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=2,9 do
			local wep = getPedWeapon(ped,i)
			if wep and wep == 41 then
				table.insert(playerWeapons,wep)
			end
		end
	end
	return playerWeapons
end
