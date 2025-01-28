--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local PJ={}

PJ.vehs={}
PJ.trailers={}
PJ.peds={}
PJ.objcs={}

PJ.pos={
    ["A"]={
        spawn={1144.0549,1313.9062,10.3404,0,0,180.1531},
        model=586,
        L={0, -1.2, 0.75},
    },
    
    ["B"]={
        spawn={1144.5039,1263.3660,10.4784,0,0,89.4062},
        model=589,
        L={0, -0.9, 1.19},
    },

    ["C"]={
        spawn={1132.3267,1251.9021,10.8101,0,0,90.9280},
        model=499,
        L={0, -0.5, 2.05},
    },

    ["C+E"]={
        spawn={1114.6080,1211.2186,11.4266,0,0,268.9911},
        model=403,
        L={0, -0.5, 2.25},
    },

    ["L1"]={
        spawn={421.7249,2512.5894,16.9427,0,0,89.1542},
        model=593,
        respawnPos={414.2760,2532.4951,19.1462}
    },

    ["L2"]={
        spawn={421.5135,2512.0198,17.8841,0,0,90.6462},
        model=511,
        respawnPos={414.2760,2532.4951,19.1462}
    },
}

-- sets

addEvent("give:pj", true)
addEventHandler("give:pj", resourceRoot, function(type, number)
    db = exports.px_connect

    local licenses = getElementData(client, "user:licenses")
    local uid = getElementData(client, "user:uid")
    if(licenses and uid)then
        licenses[string.lower(type)]=number
        setElementData(client, "user:licenses", licenses)

        dbExec(db, "UPDATE accounts SET licenses=? WHERE id=? LIMIT 1", toJSON(licenses), uid)

        if(string.upper(type) == "B" and tonumber(number) == 2)then
            if(not exports.px_achievements:isPlayerHaveAchievement(client, "Kierowca"))then
                exports.px_achievements:getAchievement(client, "Kierowca")
            end
        end
    end
end)

-- money

addEvent("take:money", true)
addEventHandler("take:money", resourceRoot, function(money)
    takePlayerMoney(client, money)
end)

-- start practice

addEvent("start:pj", true)
addEventHandler("start:pj", resourceRoot, function(type)
    local tbl=PJ.pos[type]
    if(tbl)then
        PJ.vehs[client] = createVehicle(tbl.model, unpack(tbl.spawn))
        PJ.peds[client] = createPed(57, 0, 0, 0)

        if(tbl.L)then
            PJ.objcs[client] = createObject(1860, 0, 0, 0)
            attachElements(PJ.objcs[client], PJ.vehs[client], unpack(tbl.L))
            setElementCollisionsEnabled(PJ.objcs[client], false)
        end

        setVehicleColor(PJ.vehs[client], 255, 255, 255)
        setElementData(PJ.vehs[client], "ghost", "all")
        setElementData(PJ.vehs[client],"ghost_cs",true)
        setElementData(PJ.vehs[client], "vehicle:pj", true)
        setVehicleEngineState(PJ.vehs[client], false)
        setVehicleOverrideLights(PJ.vehs[client], 1)
        warpPedIntoVehicle(PJ.peds[client], PJ.vehs[client], 1)
        setVehicleHandling(PJ.vehs[client], "maxVelocity", 60)

        if(type ~= "A")then
            setElementData(PJ.vehs[client], "vehicle:handbrake", true)

            if(type == "C+E")then
                PJ.trailers[client]=createVehicle(450, 1103.4445,1211.0132,11.3805,0,0,270.3641)
            end
        end
    end
end)

addEvent("warp:pj", true)
addEventHandler("warp:pj", resourceRoot, function(type)
    if(checkElement(PJ.vehs[client]))then
        warpPedIntoVehicle(client, PJ.vehs[client])
        setElementFrozen(PJ.vehs[client], false)
    end
end)

addEvent("destroy:pj", true)
addEventHandler("destroy:pj", resourceRoot, function(type)
    if(checkElement(PJ.vehs[client]))then
        destroyElement(PJ.vehs[client])
        PJ.vehs[client] = nil
    end

    if(checkElement(PJ.peds[client]))then
        destroyElement(PJ.peds[client])
        PJ.peds[client] = nil
    end

    if(checkElement(PJ.objcs[client]))then
        destroyElement(PJ.objcs[client])
        PJ.objcs[client] = nil
    end

    if(checkElement(PJ.trailers[client]))then
        destroyElement(PJ.trailers[client])
        PJ.trailers[client]=nil
    end

    local plr = client
    setTimer(function()
        local pos=PJ.pos[type] and PJ.pos[type].respawnPos or {1171.1909179688,1343.0025634766,10.890625}
        setElementPosition(plr,pos[1],pos[2],pos[3])
    end, 250, 1)
end)

addEventHandler("onVehicleStartExit", resourceRoot, function(plr, seat)
    if(checkElement(PJ.vehs[plr]) and PJ.vehs[plr] == source)then
        cancelEvent()
        triggerClientEvent(plr, "stop:pj", resourceRoot)

        noti = exports.px_noti
        exports.px_noti:noti("Opuściłeś pojazd i oblałeś egzamin praktyczny na prawo jazdy!", plr)
    end
end)

addEventHandler("onVehicleDamage", resourceRoot, function(loss)
    local plr = getVehicleController(source)
    if(loss > 10 and plr and checkElement(PJ.vehs[plr]) and PJ.vehs[plr] == source)then
        triggerClientEvent(plr, "stop:pj", resourceRoot)

        noti = exports.px_noti
        exports.px_noti:noti("Uszkodziłeś pojazd i oblałeś egzamin praktyczny na prawo jazdy!", plr)
    end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(plr, seat)
    if(checkElement(PJ.vehs[plr]) and PJ.vehs[plr] ~= source)then
        cancelEvent()
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if(checkElement(PJ.vehs[source]))then
        destroyElement(PJ.vehs[source])
        PJ.vehs[source] = nil
    end

    if(checkElement(PJ.peds[source]))then
        destroyElement(PJ.peds[source])
        PJ.peds[source] = nil
    end

    if(checkElement(PJ.objcs[source]))then
        destroyElement(PJ.objcs[source])
        PJ.objcs[source] = nil
    end

    if(checkElement(PJ.trailers[source]))then
        destroyElement(PJ.trailers[source])
        PJ.trailers[source]=nil
    end
end)

-- useful

function checkElement(element)
	if(element and isElement(element))then
		return true
    end
    return false
end

addCommandHandler("setlicense", function(player, cmd, targetName, licenseType, value)
    -- Verifica se o jogador que executa o comando é um administrador
    local adminUID = getElementData(player, "user:uid")  -- Obtém o UID do administrador
    if not adminUID then
        outputChatBox("❌ Erro ao obter seu UID. Tente relogar.", player, 255, 0, 0)
        return
    end

    -- Verifica o nível do administrador diretamente na database
    exports.px_connect:query("SELECT rank FROM admins WHERE uid=?", adminUID, function(result)
        if not result or #result == 0 or tonumber(result[1].rank) < 5 then
            outputChatBox("❌ Você não tem permissão para usar este comando.", player, 255, 0, 0)
            return
        end

        -- Verifica se todos os argumentos foram passados corretamente
        if not targetName or not licenseType or not value then
            outputChatBox("⚠️ Uso correto: /setlicense <player> <tipo> <valor>", player, 255, 255, 0)
            return
        end

        -- Converte a licença para maiúscula e verifica se é válida
        licenseType = string.upper(licenseType)
        local validLicenses = { ["A"] = true, ["B"] = true, ["C"] = true, ["C+E"] = true, ["L1"] = true, ["L2"] = true }
        if not validLicenses[licenseType] then
            outputChatBox("❌ Tipo de licença inválido! Use: A, B, C, C+E, L1, L2.", player, 255, 0, 0)
            return
        end

        -- Converte o valor da licença para número
        value = tonumber(value)
        if not value then
            outputChatBox("❌ O valor da licença deve ser um número!", player, 255, 0, 0)
            return
        end

        -- Obtém o jogador alvo
        local targetPlayer = getPlayerFromName(targetName)
        if not targetPlayer then
            outputChatBox("❌ Jogador não encontrado!", player, 255, 0, 0)
            return
        end

        -- Obtém o UID da conta do jogador alvo
        local targetUID = getElementData(targetPlayer, "user:uid")
        if not targetUID then
            outputChatBox("❌ Erro ao obter o UID do jogador alvo.", player, 255, 0, 0)
            return
        end

        -- Obtém as licenças atuais do jogador alvo
        local targetLicenses = getElementData(targetPlayer, "user:licenses") or {}

        -- Atualiza a licença do jogador na tabela local
        targetLicenses[licenseType] = value
        setElementData(targetPlayer, "user:licenses", targetLicenses)

        -- Atualiza a licença no banco de dados com dbExec
        local success = exports.px_connect:dbExec("UPDATE accounts SET licenses=? WHERE id=? LIMIT 1", toJSON(targetLicenses), targetUID)

        -- Verifica se a execução de dbExec foi bem-sucedida
        if success then
            outputChatBox("✅ Licença '" .. licenseType .. "' do jogador " .. getPlayerName(targetPlayer) .. " foi atualizada para " .. value .. "!", player, 0, 255, 0)
            outputChatBox("📜 Sua licença '" .. licenseType .. "' foi modificada por um administrador!", targetPlayer, 0, 255, 255)
        else
            outputChatBox("❌ Não foi possível atualizar a licença no banco de dados.", player, 255, 0, 0)
        end
    end)
end)