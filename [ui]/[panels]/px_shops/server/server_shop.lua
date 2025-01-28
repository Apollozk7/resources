--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local EAT = {}

EAT.places = {
    ["Sklep Las Venturas"]={
        {
            ped={59,2205.3423,1990.0895,12.3047,88.8039},
            name="Sklepikarz",
            text="Kasjer",
        },
    },

    ["Sklep Wioska 51"]={
        {
            ped={59,242.4082,1866.7749,19.6379,270.3925},
            name="Sklepikarz",
            text="Kasjer",
        },
    },

    ["Sklep Fort Carson"]={
        {
            ped={59,-176.2639,1025.2185,19.7422,358.9928},
            name="Sklepikarz",
            text="Kasjer",
        },
    },
}

--

-- create places

for name,v in pairs(EAT.places) do
    outputDebugString("(px_shops) ✓ Pomyślnie stworzono sprzedawców w "..name..".")

    for i,v in pairs(v) do
        v.ped_created = createPed(v.ped[1], v.ped[2], v.ped[3], v.ped[4], v.ped[5])

        setElementFrozen(v.ped_created, true)
        setElementData(v.ped_created, "ped:desc", {name=v.name, desc=v.text})

        setElementData(v.ped_created, "interaction", {options={
            {name="Rozpocznij rozmowę", alpha=0, animate=false, tex=":px_interaction/assets/images/icons/chat-icon.png"},
        }, scriptName="px_shops", dist=3})

        setElementData(v.ped_created, "dialog:name", v.name)

        setElementID(v.ped_created, "PED_"..name)
    end
end

addEventHandler('onPedWasted', resourceRoot, function()
    setElementHealth(source,100)
end)

--

-- interaction

function findAndAddToInventory(player, name, count)
    local eq = getElementData(player, "user:eq") or {}
    local exists = false

    for i,v in pairs(eq) do
        if(v and v.name == name and v.value)then
            v.value = v.value+count
            exists = true
            break
        end
    end

    setElementData(player, "user:eq", eq)

    return exists
end

function addToInventory(player, name, value)
    value=value or 1

    local eq = getElementData(player, "user:eq") or {}
    if(not findAndAddToInventory(player, name, value))then
        local exists=false
        for i = 1,#eq do
            if(not eq[i])then
                eq[i] = {name=name, value=value}
                exists=true
                break
            end
        end

        if(not exists)then
            eq[#eq+1]={name=name, value=value}
        end

        setElementData(player, "user:eq", eq)
    end
end

addEvent("buy.items", true)
addEventHandler("buy.items", resourceRoot, function(items)
    local cost=0
    local x=0
    for i,v in pairs(items) do
        cost=cost+(v.cost*v.value)
        x=x+1
    end

    if(getPlayerMoney(client) >= cost)then
        exports.px_noti:noti("Pomyślnie zakupiłeś "..x.." przedmiotów za "..cost.."$.", client, "success")

        takePlayerMoney(client, cost)

        for i,v in pairs(items) do
            addToInventory(client, i, v.value)
        end

        exports.px_discord:sendDiscordLogs("[SKLEP] Kupiono "..x.." przedmiotow za "..cost.."$", "hajs", client)
    else
        exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
    end
end)

--
