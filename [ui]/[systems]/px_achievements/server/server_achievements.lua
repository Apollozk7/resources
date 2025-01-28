local achievementsList = {}

function getAchievement(player,name)
    triggerClientEvent(player, "getAchievement", resourceRoot, name)
end

function getAchievementByID(id)
    return achievementsList[id]
end

function getAchievementByName(name)
    local returnData = false

    for id, achievementData in pairs(achievementsList) do
        if(achievementData.title == name) then
            returnData = achievementData
            break
        end
    end

    return returnData
end

function isAchievementCompleted(currentAchievements, achievementData)
    local returnData = false

    for i,v in ipairs(currentAchievements) do
        if tonumber(v) == achievementData.id then
            returnData = true
            break
        end
    end
    
    return returnData
end

function isPlayerHaveAchievement(player,name)
    local list = getElementData(player, "user:achievements") or {}
    return list[name]
end

function getAchievements()
    return achievementsList
end

addEvent("addAchievement", true)
addEventHandler("addAchievement", resourceRoot, function(title)
    local getAchievement = getAchievementByName(title)
    if(getAchievement)then
        local list = getElementData(client, "user:achievements") or {}

        if(not list[title])then
            list[title] = true
            setElementData(client, "user:achievements", list)

            local achievementData = getAchievementByName(title)

            local playerUID = getElementData(client, "user:uid")
            local currentPlayerData = exports.px_connect:query("SELECT achievements FROM accounts WHERE id=?", playerUID)
            local currentAchievements = split(currentPlayerData[1].achievements, ", ") or {}

            if(not isAchievementCompleted(currentAchievements, achievementData))then
                table.insert(currentAchievements, achievementData.id)
                exports.px_connect:query("UPDATE accounts SET achievements=? WHERE id=?", table.concat(currentAchievements, ", "), playerUID)
                triggerClientEvent(client, "showAchievement", resourceRoot, achievementData)

                local rp=getElementData(client, 'user:reputation')
                setElementData(client, 'user:reputation', rp+achievementData.moneyPrize)
            end
        end
    else
        iprint("[px_achievements] Invalid achievement name:", title)
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    local q = exports.px_connect:query("SELECT * FROM achievements")

    for i,v in ipairs(q) do
        achievementsList[v.id] = {id = v.id, title = v.title, description = v.description, moneyPrize = v.moneyPrize}
    end

    print("[px_achievements] Loaded "..#q.." achievements!")
end)